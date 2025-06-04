# frozen_string_literal: true

require_relative 'container_element'

module Metadocs
  module Elements
    class TableRow < ContainerElement
      def cells
        children
      end
    end
  end
end
