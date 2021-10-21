# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Body < Elements::Element
      include Enumerable

      attr_accessor :children

      def initialize(children: [])
        super()
        raise ArgumentError, 'Children must be an array' unless children.is_a?(Array)

        @children = children
      end

      def each(&blk)
        children.each(&blk)
      end

      def <<(child)
        children << child
      end

      def [](idx)
        children[idx]
      end
    end
  end
end
