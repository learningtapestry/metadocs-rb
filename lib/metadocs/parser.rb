# frozen_string_literal: true

require 'hashie'
require_relative 'parser_error'
require_relative 'google_document'
require_relative 'source_map'
require_relative 'bbdocs'
require_relative 'elements'
require_relative 'paragraph_ranges'
require_relative 'html_renderer'
require_relative 'text_renderer'

module Metadocs
  class Parser
    include Enumerable

    DEFAULT_RENDERERS = {
      html: Metadocs::HtmlRenderer,
      text: Metadocs::TextRenderer
    }.freeze

    attr_reader :google_document, :tags, :empty_tags, :source_map, :bbdocs, :images, :body,
                :metadata, :metadata_tables, :renderers, :metadoc_properties

    def initialize(google_document, tags: [], empty_tags: [], metadata_tables: [], renderers: {})
      @google_document = google_document
      @tags = tags
      @empty_tags = empty_tags
      @metadata = {}
      @metadata_tables = metadata_tables
      @images = {}
      @renderers = {}.merge(DEFAULT_RENDERERS).merge(renderers)
      @metadoc_properties = {}

      image_candidates = Array(google_document.inline_objects) + Array(google_document.positioned_objects)
      image_candidates.each do |id, object|
        object_properties = object.try(:inline_object_properties) || object.try(:positioned_object_properties)
        properties = object_properties.embedded_object
        next unless properties.image_properties || properties.embedded_drawing_properties
        dimensions = properties.size
        width = "#{dimensions.width.magnitude}#{dimensions.width.unit}" if dimensions.width
        height = "#{dimensions.height.magnitude}#{dimensions.height.unit}" if dimensions.height
        image_meta = {
          inline_object: object,
          title: properties.title,
          description: properties.description,
          width: width,
          height: height
        }
        if properties.image_properties.present?
          image_meta[:content_uri] = properties.image_properties.content_uri
          image_meta[:source_uri] = properties.image_properties.source_uri
        elsif properties.embedded_drawing_properties.present?
          image_meta[:is_drawing] = true
        end
        images[id] = Hashie::Mash.new(image_meta)
      end
    end

    def self.parse(google_authorization, doc_id, tags: [], empty_tags: [], metadata_tables: [], renderers: [])
      document = Metadocs::GoogleDocument.new(google_authorization, doc_id)
      parser = new(
        document.document,
        tags: tags,
        empty_tags: empty_tags,
        metadata_tables: metadata_tables,
        renderers: renderers
      )
      parser.parse
      parser
    end

    def parse
      @source_map = Metadocs::SourceMap.new(google_document)
      @bbdocs = Metadocs::Bbdocs.new(
        tags: tag_names,
        empty_tags: empty_tag_names,
        ignore_tags: metadata_table_names
      )

      source_map.generate

      @ranges = ParagraphRanges.new(source_map)
      @body = Elements::Body.with_renderers(
        renderers,
        children: walk_ast(source_map.body, bbdocs.parse(source_map.body.source))
      )
      @metadoc_properties = @metadata.values.first&.reduce(&:merge)
    rescue StandardError => e
      if e.is_a?(Metadocs::BbdocsError)
        raise
      else
        raise ParserError.new(e.message)
      end
    end

    def each(&blk)
      body.each(&blk)
    end

    def [](idx)
      if idx.is_a?(Numeric)
        body[idx]
      else
        metadata[idx]
      end
    end

    protected

    attr_reader :ranges

    def tag_names
      @tag_names ||= tags.map { |t| t[:name] }
    end

    def empty_tag_names
      @empty_tag_names ||= empty_tags.map { |t| t[:name] }
    end

    def metadata_table_names
      @metadata_table_names ||= metadata_tables.map { |mtt| mtt[:name] }
    end

    def walk_ast(mapping, ast)
      children = []
      ast.each do |node|
        if node[:tag] || node[:empty_tag]
          tag = parse_tag(mapping, node)
          if tag
            tag.structural_element = find_tag_structural_element(mapping, node)
            children << tag
          end
        elsif node[:reference]
          reference = parse_reference(mapping, node)
          children << reference if reference
        elsif node[:text]
          struct_paragraphs = parse_text(mapping, node).group_by { |(struct, _paragraph)| struct }
          struct_paragraphs.each do |struct_paragraph, paragraph_elements|
            texts = paragraph_elements.map { |p| p[1..] }.flatten
            if struct_paragraph.paragraph.bullet
              p_attrs = struct_paragraph.paragraph
              list_id = p_attrs.bullet.list_id
              list_properties = google_document.lists[list_id].list_properties
              nesting_level = p_attrs.bullet.nesting_level.to_i
              glyph_type = list_properties.nesting_levels[nesting_level].glyph_type
              glyph_symbol = list_properties.nesting_levels[nesting_level].glyph_symbol
              paragraph = Elements::ListItem.with_renderers(
                renderers,
                list_id: p_attrs.bullet.list_id,
                nesting_level: nesting_level,
                glyph_type: glyph_type,
                glyph_symbol: glyph_symbol,
                children: texts
              )
            else
              paragraph = Elements::Paragraph.with_renderers(
                renderers,
                children: texts
              )
            end
            paragraph.structural_element = struct_paragraph
            children << paragraph
          end
        end
      end

      merge_paragraphs(children)
    end

    def find_tag_structural_element(mapping, node)
      tag = node[:tag]
      if tag[:empty_tag]
        tag_name = tag[:empty_tag][:name]
        start_at = tag_name.offset
        end_at = start_at + tag_name.length
      else
        tag_name = tag[:start_tag][:name]
        start_at = tag_name.offset
        end_at = tag[:end_tag][:name].offset + tag[:end_tag][:name].length
      end
      start_at_range = ranges.find_paragraph(mapping.element, start_at)
      end_at_range = ranges.find_paragraph(mapping.element, end_at)

      return start_at_range[0] if start_at_range[0] == end_at_range[0]
    end

    def parse_tag(mapping, node)
      tag = node[:tag]
      open_tag = tag[:start_tag] || tag[:empty_tag]
      name = open_tag[:name].str
      children = tag[:children] ? walk_ast(mapping, tag[:children]) : []
      attributes = nil
      if open_tag[:attributes]&.any?
        attributes = {}
        open_tag[:attributes].each do |attr|
          attributes[attr[:name].str] = attr[:value].str
        end
      end

      Elements::Tag.with_renderers(
        renderers,
        name: name,
        children: children,
        attributes: Hashie::Mash.new(attributes),
        qualifier: open_tag[:qualifier]&.str,
        empty: tag[:empty_tag] ? true : false
      )
    end

    def parse_reference(mapping, node)
      reference_mapping = source_map[node[:reference][:value].str]
      case reference_mapping.type
      when :paragraph_element, :list_item_element
        return parse_paragraph_reference(mapping, reference_mapping, node)
      when :table
        return parse_table_reference(mapping, reference_mapping, node)
      end

      nil
    end

    def parse_paragraph_reference(_mapping, reference_mapping, _node)
      paragraph_element = reference_mapping.paragraph_element
      return unless paragraph_element.inline_object_element

      id = paragraph_element.inline_object_element.inline_object_id
      image = images[id]

      return nil unless image

      Elements::Image.with_renderers(
        renderers,
        id: id,
        content_uri: image.content_uri,
        source_uri: image.source_uri,
        title: image.title,
        description: image.description
      )
    end

    def parse_table_reference(_mapping, reference_mapping, _node)
      table = Elements::Table.with_renderers(renderers)

      reference_mapping.table_rows.each do |cell_ids|
        row = Elements::TableRow.with_renderers(renderers)
        table.rows << row
        cell_ids.each do |cell_id|
          cell_mapping = source_map[cell_id]
          cell = Elements::TableCell.with_renderers(
            renderers,
            column_span: cell_mapping['element'].table_cell_style.column_span,
            row_span: cell_mapping['element'].table_cell_style.row_span,
          )
          row.cells << cell

          cell_bbdocs = Metadocs::Bbdocs.new(
            tags: tag_names,
            empty_tags: empty_tag_names,
            ignore_tags: metadata_table_names
          )
          cell.children = walk_ast(cell_mapping, cell_bbdocs.parse(cell_mapping.source))
        end
      end

      metadata_tables.each do |mtt|
        metadata_table = Elements::MetadataTable.with_renderers(
          renderers,
          table: table,
          name: mtt[:name],
          type: mtt[:type]
        )
        next unless metadata_table.valid?

        metadata[metadata_table.name] ||= []
        metadata[metadata_table.name] << metadata_table.metadata
        return metadata_table
      end

      table
    end

    def parse_text(mapping, node)
      full_text = node[:text].str
      paragraphs = ranges.find_paragraphs(mapping.element, node[:text].offset, full_text)
      paragraphs.map do |(structural_element, paragraph_element, text)|
        [
          structural_element,
          Elements::Text.with_renderers(
            renderers,
            value: text,
            bold: paragraph_element.text_run.text_style.bold ? true : false,
            italic: paragraph_element.text_run.text_style.italic ? true : false,
            underline: paragraph_element.text_run.text_style.underline ? true : false,
            strikethrough: paragraph_element.text_run.text_style.strikethrough ? true : false
          )
        ]
      end
    end

    # Merge tags and paragraphs.
    def merge_paragraphs(children)
      merged_children = []

      # Accumulate all children that belong to the same structural element
      struct_children = {}
      children.each_with_index do |child, idx|
        key = child.structural_element || idx
        struct_children[key] ||= []
        struct_children[key] << child
      end

      struct_children.each do |key, key_children|
        if key.is_a?(Numeric)
          # Append unrelated children
          merged_children.push(*key_children)
        else
          # Merge related children
          parent_paragraph_idx = key_children.index { |c| c.is_a?(Elements::Paragraph) }
          raise ParserError.new("Invalid nesting of tags—check the input.") if parent_paragraph_idx.nil?
          parent_paragraph = key_children[parent_paragraph_idx]
          if parent_paragraph_idx.positive?
            parent_paragraph.children.insert(0, *key_children[0...parent_paragraph_idx])
          end
          if parent_paragraph_idx + 1 < key_children.length
            parent_paragraph.children.push(*key_children[parent_paragraph_idx + 1...key_children.length])
          end

          # Flatten inner tag paragraphs
          parent_paragraph.children.each do |child|
            next unless child.is_a?(Elements::Tag)

            child.children = child.children.map do |c|
              c.is_a?(Elements::Paragraph) ? c.children : c
            end.flatten
          end

          # Flatten inner paragraphs
          parent_paragraph.children = parent_paragraph.children.map do |child|
            child.is_a?(Elements::Paragraph) ? child.children : child
          end.flatten

          merged_children << parent_paragraph
        end
      end

      merged_children
    end
  end
end
