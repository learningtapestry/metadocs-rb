# frozen_string_literal: true

require_relative 'container_element'

module Metadocs
  module Elements
    class TableRow < ContainerElement
      attr_accessor :table_row_element

      def cells
        children
      end
    end
  end
end
