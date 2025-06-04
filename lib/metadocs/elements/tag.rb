# frozen_string_literal: true

require_relative 'container_element'

module Metadocs
  module Elements
    class Tag < ContainerElement
      attr_accessor :name, :parent, :attributes, :qualifier, :empty

      def initialize(
        renderers:,
        name:,
        children: [],
        attributes: {},
        qualifier: nil,
        empty: false
      )
        super(renderers: renderers, children: children)
        @name = name
        @attributes = attributes
        @qualifier = qualifier
        @empty = empty
      end

      def empty?
        empty
      end
    end
  end
end
