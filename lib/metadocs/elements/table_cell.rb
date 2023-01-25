# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class TableCell < Elements::Element
      has_children
      attr_accessor :column_span, :row_span

      def initialize(column_span: nil, row_span: nil, children: [])
        super()
        raise ArgumentError, 'Children must be an array' unless children.is_a?(Array)

        @children = children
        @column_span = column_span
        @row_span = row_span
      end
    end
  end
end
