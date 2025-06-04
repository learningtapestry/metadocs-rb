# frozen_string_literal: true

require_relative 'container_element'

module Metadocs
  module Elements
    class Table < ContainerElement
      attr_accessor :metadata_table

      def rows
        children
      end
    end
  end
end
