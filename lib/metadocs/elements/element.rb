# frozen_string_literal: true

require 'json'

module Metadocs
  class Elements::Element
    attr_accessor :structural_element, :parser
    attr_reader :id

    DEFAULT_RENDERER = :text

    def initialize(parser)
      @id = short_id
      @parser = parser
    end

    def renderers
      parser.renderers
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

    def to_h
      {
        id: id,
        type: self.class.name.split('::').last.downcase
      }
    end

    def to_json(*args)
      to_h.to_json(*args)
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

    ID_CHARS = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten.freeze

    def short_id(length = 4)
      Array.new(length) { ID_CHARS[SecureRandom.random_number(ID_CHARS.size)] }.join
    end
  end
end
