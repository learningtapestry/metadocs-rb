# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Table < Elements::Element
      include Elements::ContainerMethods

      alias_attr :children, :rows
      attr_accessor :metadata_table

      def initialize(rows: [])
        super()
        self.rows = rows
      end
    end
  end
end
