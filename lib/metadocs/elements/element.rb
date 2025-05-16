# frozen_string_literal: true

require_relative 'container_methods'

module Metadocs
  class Elements::Element
    attr_accessor :renderers, :structural_element
    attr_reader :id

    DEFAULT_RENDERER = :text

    def self.with_renderers(renderers, attrs = {})
      new_element = new(**attrs)
      new_element.renderers = renderers
      new_element
    end

    def self.alias_attr(new_method, old_method)
      alias_method :"#{old_method}", :"#{new_method}"
      alias_method :"#{old_method}=", :"#{new_method}="
    end

    def initialize
      @id = SecureRandom.hex(4)
    end

    def render(renderer_type = DEFAULT_RENDERER, parser_options = {})
      renderer = renderers[renderer_type]

      self.renderer_instances ||= {}
      self.renderer_instances[renderer_type] ||= renderer[:type].new(
        renderer_type,
        self,
        {}.merge(renderer[:parser_options] || {}, parser_options)
      )
      self.renderer_instances[renderer_type].render
    end

    def body?
      is_a?(Elements::Body)
    end

    def image?
      is_a?(Elements::Image)
    end

    def metadata_table?
      is_a?(Elements::Table) && metadata_table
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
