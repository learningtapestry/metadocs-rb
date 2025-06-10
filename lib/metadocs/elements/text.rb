# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Text < Elements::Element
      attr_accessor :value, :bold, :italic, :underline, :strikethrough

      def initialize(
        renderers:,
        value:, bold: false, italic: false, underline: false, strikethrough: false
      )
        super(renderers: renderers)
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
    end
  end
end
