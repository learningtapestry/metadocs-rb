# frozen_string_literal: true

require_relative 'paragraph'

module Metadocs
  module Elements
    class ListItem < Elements::Paragraph
      attr_accessor :list_id, :nesting_level, :glyph_type, :glyph_symbol

      has_children

      def initialize(list_id:, nesting_level:, glyph_type:, glyph_symbol:, children: [])
        super()

        @children = children
        @list_id = list_id
        @nesting_level = nesting_level
        @glyph_type = glyph_type
        @glyph_symbol = glyph_symbol
      end

      BULLET_GLYPHS = %w[● ○ ■ ❖ ➢ ➔ ◆ ★ -].freeze

      def bulleted?
        BULLET_GLYPHS.include?(@glyph_symbol) || @glyph_type == "GLYPH_TYPE_UNSPECIFIED"
      end

      NUMBER_TYPES = %w[DECIMAL ALPHA ROMAN].freeze

      def numbered?
        NUMBER_TYPES.include?(@glyph_type)
      end

      def checklist?
        @glyph_type == "GLYPH_TYPE_UNSPECIFIED"
      end
    end
  end
end
