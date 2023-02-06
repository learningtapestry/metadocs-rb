# frozen_string_literal: true

require_relative 'renderer'

module Metadocs
  class TextRenderer < Renderer
    protected

    def render_body
      render_children.strip
    end

    def render_image
      "IMG #{element.url}"
    end

    def render_key_value_table
      element.metadata.transform_values do |v|
        v.render(type)
      end.to_s
    end

    def render_paragraph
      render_children
    end

    def render_list_item
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

    def render_tag
      render_children
    end

    def render_tuple_table
      element.metadata.map do |entry|
        entry.transform_values do |v|
          v.render(type)
        end.to_h
      end.to_s
    end

    def render_text
      element.value
    end
  end
end
