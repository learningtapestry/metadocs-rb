# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Table < Elements::Element
      attr_accessor :rows

      def initialize(rows: [])
        super()
        @rows = rows
      end
    end
  end
end
