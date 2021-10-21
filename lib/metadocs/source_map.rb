# frozen_string_literal: true

require 'securerandom'
require 'hashie'

module Metadocs
  class SourceMap < Hashie::Mash
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def generate
      walk_content
    end

    protected

    def walk_content(uuid = 'body', location = nil)
      source = ''
      text_paragraphs = []
      element = document.body
      content = element.content

      location&.each_with_index do |element_location, _idx|
        element = content[element_location[0]]
        type = find_type(element)
        content = if type == :table
                    element = element
                                .table
                                .table_rows[element_location[1]]
                                .table_cells[element_location[2]]
                    element.content
                  else
                    element.send(type).content
                  end
      end

      content.each_with_index do |struct_element, idx|
        element_uuid = SecureRandom.hex(4)
        type = find_type(struct_element)

        if type == :paragraph
          struct_element.paragraph.elements.each_with_index do |paragraph_element, para_idx|
            para_uuid = SecureRandom.hex(4)
            begin_at = source.length
            if paragraph_element.text_run
              source += paragraph_element.text_run.content
              text_paragraphs << para_uuid
            else
              source += wrap_uuid(para_uuid)
            end

            self[para_uuid] = Hashie::Mash.new({
                                                 type: :paragraph_element,
                                                 element: element,
                                                 paragraph_element: paragraph_element,
                                                 structural_element: struct_element,
                                                 source_location: begin_at...source.length,
                                                 location: (location || []) + [idx, para_idx]
                                               })
          end
        else
          source += wrap_uuid(element_uuid)

          self[element_uuid] = Hashie::Mash.new({
                                                  type: type,
                                                  element: element,
                                                  structural_element: struct_element,
                                                  location: (location || []) + [idx],
                                                  table_rows: []
                                                })

          case type
          when :table
            struct_element.table.table_rows.each_with_index do |row, row_idx|
              row_cells = []
              row.table_cells.each_with_index do |_cell, cell_idx|
                cell_uuid = SecureRandom.hex(4)
                row_cells << cell_uuid
                new_location = (location || []) + [[idx, row_idx, cell_idx]]
                walk_content(cell_uuid, new_location)
              end
              self[element_uuid][:table_rows] << row_cells
            end
          when :table_of_contents
            new_location = (location || []) + [[idx]]
            walk_content(element_uuid, new_location)
          end
        end
      end

      self[uuid] = Hashie::Mash.new({
                                      element: element,
                                      source: source,
                                      text_paragraphs: text_paragraphs,
                                      location: location
                                    })
    end

    def find_type(struct_element)
      if struct_element.paragraph
        :paragraph
      elsif struct_element.section_break
        :section_break
      elsif struct_element.table
        :table
      elsif struct_element.table_of_contents
        :table_of_contents
      else
        raise ArgumentError, 'Unknown structural element type'
      end
    end

    def wrap_uuid(uuid)
      "[$:#{uuid}]"
    end
  end
end
