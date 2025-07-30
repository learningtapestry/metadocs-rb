# frozen_string_literal: true

require_relative 'element'

module Metadocs
  class Elements::MetadataTable < Elements::Element
    attr_reader :error, :table, :name, :type

    include Enumerable

    def initialize(parser, table:, name:, type:)
      super(parser)
      @table = table
      @name = name.to_s
      @type = type.to_sym

      raise ArgumentError, "Unknown type: #{type}" unless %i(key_value tuple).include?(self.type)
    end

    def each(&blk)
      metadata.each(&blk)
    end

    def [](idx)
      metadata[idx]
    end

    def valid?
      !metadata.nil?
    end

    def tuple?
      type == :tuple
    end

    def key_value?
      type == :key_value
    end

    def rows
      table.rows
    end

    def metadata
      @metadata ||= parse_metadata
    end

    def header_cells
      rows[1].cells
    end

    def to_h
      element_super = Elements::Element.instance_method(:to_h).bind(self).call
      hash = element_super.merge(
        name: full_name,
        type: type,
        valid: valid?
      )

      hash[:error] = error if error
      hash[:metadata] = serialize_metadata if valid?
      hash
    end

    protected

    def serialize_metadata
      if tuple?
        metadata.map do |entry|
          entry.transform_values { |v| v.respond_to?(:to_h) ? v.to_h : v }
        end
      elsif key_value?
        metadata.transform_values { |v| v.respond_to?(:to_h) ? v.to_h : v }
      else
        metadata
      end
    end

    def name_cell
      rows[0].cells[0]
    end

    def parse_metadata
      if rows.empty?
        @error = 'Table is empty'
        return nil
      end

      # is_all_text = all_text?(name_cell)
      # is_single_tag = single_tag?(name_cell)
      # unless is_all_text || is_single_tag
      #   @error = 'Title row can only have text elements or a single tag element'
      #   return nil
      # end

      #row_name = is_all_text ? join_text(name_cell).strip : get_tag_name(name_cell)
      row_name = name_cell.render(:text).strip
      if ![name, "[#{name}]"].include?(row_name)
        @error = "Expected name to be #{name}, but is #{row_name}"
        return nil
      end

      if tuple? && rows.length < 2
        @error = 'Tuple-type tables must have at least 2 rows'
        return nil
      end

      if tuple?
        parse_tuples
      elsif key_value?
        parse_key_values
      else
        @error = "Unknown type: #{type}"
        nil
      end
    end

    def parse_key_values
      data = {}
      data_rows = rows[1..]

      unless data_rows.all? { |r| r.cells.length == 2 }
        @error = 'Data rows must have 2 cells'
        return nil
      end

      data_rows.each do |row|
        key_cell, value_cell = row.cells

        unless all_text?(key_cell)
          @error = 'Key cells must only have text elements'
          return nil
        end

        key = join_text(key_cell).downcase
        next if key.empty?

        data[key] = Elements::Body.new(parser, value_cell.children.dup)
      end

      data
    end

    def parse_tuples
      data = []
      data_rows = rows[2..]

      headers = header_cells.map { |c| join_text(c).downcase }
      if headers.any?(&:empty?)
        @error = 'Headers must not be empty'
        return nil
      end

      unless data_rows.all? { |r| r.cells.length == header_cells.length }
        @error = 'All data rows must have the same number of cells as the header row'
        return nil
      end

      data_rows.each do |row|
        entry = {}
        headers.each_with_index do |header, idx|
          entry[header] = Elements::Body.new(parser, row.cells[idx].children.dup)
        end

        next if entry.values.all? { |c| all_text?(c) && join_text(c).empty? }

        data << entry
      end

      data
    end

    def all_text?(cell)
      cell.children.all? do |e|
        e.is_a?(Elements::Paragraph) && e.children.all? { |t| t.is_a?(Elements::Text) }
      end
    end

    def single_tag?(cell)
      cell.is_a?(Elements::Tag) || \
        (cell.respond_to?(:children) &&
          cell.children.length == 1 &&
          cell.children.first.is_a?(Elements::Tag))
    end

    def count_tags(element)
      if element.is_a?(Elements::Tag)
        1
      elsif element.respond_to?(:children)
        element.children.sum { |child| count_tags(child) }
      else
        0
      end
    end

    def join_text(cell)
      cell.children.map { |p| p.children.map(&:value) }.flatten.join.strip
    end

    def get_tag_name(cell)
      cell.children[0].children[0].name
    end

    def full_name
      row_name = if all_text?(name_cell)
                   join_text(name_cell).strip
                 else
                   name_cell.children[0].children[0].full_name
                 end
      if row_name.start_with?('[')
        row_name
      else
        "[#{row_name}]"
      end
    end
  end
end
