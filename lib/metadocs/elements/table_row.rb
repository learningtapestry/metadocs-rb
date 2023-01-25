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

      def perceptible_cells
        p_cells = []
        i = 0
        while i < cells.count
          cell = cells[i]
          p_cells << cell
          i += cell.column_span
        end
        p_cells
      end
    end
  end
end
