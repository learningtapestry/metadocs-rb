# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class TableRow < Elements::Element
      has_children

      alias_attr :children, :cells

      def initialize(cells: [])
        super()
        self.cells = cells
      end
    end
  end
end
