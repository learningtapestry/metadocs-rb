# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class ContainerElement < Elements::Element
      include Enumerable

      attr_accessor :children

      def initialize(renderers:, children: [])
        super(renderers: renderers)
        @children = children
      end

      def each(&blk)
        children.each(&blk)
      end

      def [](idx)
        children[idx]
      end

      def to_h
        Elements::Element.instance_method(:to_h).bind(self).call.merge(
          children: children.map(&:to_h)
        )
      end
    end
  end
end
