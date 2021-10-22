# frozen_string_literal: true

module Metadocs
  class Renderer
    attr_reader :element, :type

    def initialize(type, element)
      @type = type
      @element = element
    end

    def render
      if one_of?(Elements::Body)
        render_body
      elsif one_of?(Elements::Equation)
        render_equation
      elsif one_of?(Elements::Image)
        render_image
      elsif one_of?(Elements::MetadataTable)
        render_metadata_table
      elsif one_of?(Elements::Paragraph)
        render_paragraph
      elsif one_of?(Elements::TableCell)
        render_table_cell
      elsif one_of?(Elements::TableRow)
        render_table_row
      elsif one_of?(Elements::Table)
        render_table
      elsif one_of?(Elements::Tag)
        render_tag
      elsif one_of?(Elements::Text)
        render_text
      else
        raise ArgumentError, 'Unknown element type'
      end
    end

    protected

    def one_of?(*klasses)
      klasses.any? { |klass| element.is_a?(klass) }
    end

    def render_all(elements)
      elements.map { |element| element.render(type) }
    end

    def render_children
      render_all(element.children).join
    end

    def render_body; end

    def render_equation; end

    def render_image; end

    def render_key_value_table; end

    def render_metadata_table
      if element.tuple?
        render_tuple_table
      elsif element.key_value?
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
      self.send(render_method) if self.respond_to?(render_method, true)
    end

    def render_tuple_table; end

    def render_text; end
  end
end
