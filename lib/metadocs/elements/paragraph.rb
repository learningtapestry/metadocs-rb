# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Paragraph < Elements::Element
      include Enumerable

      attr_accessor :children

      def initialize(children: [])
        super()
        raise ArgumentError, 'Children must be an array' unless children.is_a?(Array)

        @children = children
      end
    end
  end
end
