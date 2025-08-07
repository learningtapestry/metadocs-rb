# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Text < Elements::Element
      attr_accessor :value, :bold, :italic, :underline, :strikethrough,
                    :paragraph_element

      def initialize(
        parser,
        value:, bold: false, italic: false, underline: false, strikethrough: false
      )
        super(parser)
        @value = value
        @bold = bold
        @italic = italic
        @underline = underline
        @strikethrough = strikethrough
      end

      def to_h
        super.merge(
          value: value,
          bold: bold,
          italic: italic,
          underline: underline,
          strikethrough: strikethrough
        )
      end

      def bold?
        bold
      end

      def italic?
        italic
      end

      def underline?
        underline
      end

      def strikethrough?
        strikethrough
      end

      def text_run
        paragraph_element.text_run
      end
    end
  end
end
