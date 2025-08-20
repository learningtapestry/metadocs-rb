# frozen_string_literal: true

module Metadocs
  class ElementRenderer
    attr_reader :renderer_id, :element

    def initialize(renderer_id, element)
      @renderer_id = renderer_id
      @element = element
    end

    def render(render_options = {})
      @render_options = render_options

      if element.body?
        render_body
      elsif element.image?
        render_image
      elsif element.metadata_table?
        render_metadata_table
      elsif element.paragraph?
        render_paragraph
      elsif element.table_cell?
        render_table_cell
      elsif element.table_row?
        render_table_row
      elsif element.table?
        render_table
      elsif element.tag?
        render_tag
      elsif element.text?
        render_text
      else
        raise ArgumentError, 'Unknown element type'
      end
    end

    protected

    def metadata_element
      element.metadata_table
    end

    def render_all(elements)
      elements.map { |element| element.render(renderer_id) }
    end

    def render_children
      render_all(element.children).join
    end

    def render_body; end

    def render_image; end

    def render_key_value_table; end

    def render_metadata_table
      if metadata_element.tuple?
        render_tuple_table
      elsif metadata_element.key_value?
        render_key_value_table
      else
        raise ArgumentError, 'Unknown table type'
      end
    end

    def render_paragraph; end

    def render_table; end

    def render_table_row; end

    def render_table_cell; end

    def render_tag
      render_method = :"render_#{element.name.underscore.downcase}"
      send(render_method) if respond_to?(render_method, true)
    end

    def render_tuple_table; end

    def render_text; end
  end
end
