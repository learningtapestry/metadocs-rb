# frozen_string_literal: true

require_relative 'renderer'

module Metadocs
  class TextRenderer < Renderer
    protected

    def render_body
      render_children.strip.gsub(/\n{3,}/, "\n\n")
    end

    def render_image
      "IMG #{element.url}"
    end

    def render_key_value_table
      table_rows = metadata_element.metadata.transform_values do |v|
        v.render(type)
      end.to_s
      "#{metadata_element.full_name}\n#{table_rows}"
    end

    def render_paragraph
      render_children
    end

    def render_table
      render_children
    end

    def render_table_row
      render_children
    end

    def render_table_cell
      render_children
    end

    def render_tuple_table
      table_rows = metadata_element.metadata.map do |entry|
        entry.transform_values do |v|
          v.render(type)
        end.to_h
      end.to_s
      "#{metadata_element.full_name}\n#{table_rows}"
    end

    def render_tag
      element.full_name
    end

    def render_text
      element.value
    end
  end
end
