# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Tag < Elements::Element
      include Elements::ContainerMethods

      attr_accessor :name, :parent, :attributes, :qualifier, :empty

      def initialize(
        name:,
        children: [],
        attributes: {},
        qualifier: nil,
        empty: false
      )
        super()
        @name = name
        @children = children
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
