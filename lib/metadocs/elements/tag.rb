# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Tag < Elements::Element
      has_children

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
