# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class TableRow < Elements::Element
      attr_accessor :cells

      def initialize(cells: [])
        super()
        @cells = cells
      end
    end
  end
end
