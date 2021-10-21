# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Equation < Elements::Element
      attr_accessor :value

      def initialize(value:)
        super()
        @value = value
      end
    end
  end
end
