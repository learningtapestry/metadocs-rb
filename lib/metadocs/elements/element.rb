# frozen_string_literal: true

module Metadocs
  class Elements::Element
    attr_accessor :renderers, :structural_element

    DEFAULT_RENDERER = :text

    def self.with_renderers(renderers, attrs = {})
      new_element = new(attrs)
      new_element.renderers = renderers
      new_element
    end

    def self.has_children
      include Enumerable

      attr_accessor :children

      define_method :each do |&blk|
        children.each(&blk)
      end

      def <<(child)
        children << child
      end

      def [](idx)
        children[idx]
      end
    end

    def self.alias_attr(new_method, old_method)
      alias_method :"#{old_method}", :"#{new_method}"
      alias_method :"#{old_method}=", :"#{new_method}="
    end

    def render(renderer_type = DEFAULT_RENDERER)
      self.renderer_instances ||= {}
      self.renderer_instances[renderer_type] ||= renderers[renderer_type].new(renderer_type, self)
      self.renderer_instances[renderer_type].render
    end

    def body?
      is_al(Elements::Body)
    end

    def equation?
      is_a?(Elements::Equation)
    end

    def image?
      is_a?(Elements::Image)
    end

    def metadata_table?
      is_a?(Elements::MetadataTable)
    end

    def paragraph?
      is_a?(Elements::Paragraph)
    end

    def table_cell?
      is_a?(Elements::TableCell)
    end

    def table_row?
      is_a?(Elements::TableRow)
    end

    def table?
      is_a?(Elements::Table)
    end

    def tag?
      is_a?(Elements::Tag)
    end

    def text?
      is_a?(Elements::Text)
    end

    protected

    attr_accessor :renderer_instances
  end
end
