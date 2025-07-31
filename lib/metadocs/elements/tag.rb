# frozen_string_literal: true

require_relative 'container_element'

module Metadocs
  module Elements
    class Tag < ContainerElement
      attr_accessor :name, :parent, :attributes, :qualifier, :empty

      def initialize(
        parser,
        children = [],
        name:,
        attributes: {},
        qualifier: nil,
        empty: false
      )
        super(parser, children)
        @name = name.downcase
        @attributes = attributes
        @qualifier = qualifier
        @empty = empty
      end

      def empty?
        empty
      end

      def to_h
        super.merge(
          name: name,
          attributes: attributes,
          qualifier: qualifier,
          empty: empty
        )
      end

      def full_name
        f_name = qualifier ? "#{name}:#{qualifier}" : name
        if f_name.start_with?('[')
          f_name
        else
          "[#{f_name}]"
        end
      end
    end
  end
end
