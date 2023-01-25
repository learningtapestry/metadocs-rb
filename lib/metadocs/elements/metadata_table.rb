# frozen_string_literal: true

require_relative 'element'

module Metadocs
  class Elements::MetadataTable < Elements::Element
    attr_reader :error, :table, :name, :type

    include Enumerable

    def initialize(table:, name:, type:)
      super()
      @table = table
      @name = name.to_s
      @type = type.to_sym

      raise ArgumentError, "Unknown type: #{type}" unless %i(key_value tuple).include?(self.type)
    end

    def each(&blk)
      metadata.each(&blk)
    end

    def [](idx)
      metadata[idx]
    end

    def valid?
      !metadata.nil?
    end

    def tuple?
      type == :tuple
    end

    def key_value?
      type == :key_value
    end

    def rows
      table.rows
    end

    def metadata
      @metadata ||= parse_metadata
    end

    def header_cells
      rows[1].cells
    end

    def perceptible_header_cells
      rows[1].perceptible_cells
    end

    protected

    def parse_metadata
      if rows.empty?
        @error = 'Table is empty'
        return nil
      end

      name_cell = rows[0].cells[0]
      unless all_text?(name_cell)
        @error = 'Title row can only have text elements'
        return nil
      end

      row_name = join_text(name_cell).strip
      if ![name, "[#{name}]"].include?(row_name)
        @error = "Expected name to be #{name}, but is #{row_name}"
        return nil
      end

      if tuple? && perceptible_cells.length < 2
        @error = 'Tuple-type tables must have at least 2 rows'
        return nil
      end

      if tuple?
        parse_tuples
      elsif key_value?
        parse_key_values
      else
        @error = "Unknown type: #{type}"
        nil
      end
    end

    def parse_key_values
      data = {}
      data_rows = rows[1..]

      unless data_rows.all? { |r| r.perceptible_cells.length == 2 }
        @error = 'Data rows must have 2 cells'
        return nil
      end

      data_rows.each do |row|
        key_cell, value_cell = row.perceptible_cells

        unless all_text?(key_cell)
          @error = 'Key cells must only have text elements'
          return nil
        end

        key = join_text(key_cell).downcase
        next if key.empty?

        data[key] = Elements::Body.with_renderers(renderers, children: value_cell.children.dup)
      end

      data
    end

    def parse_tuples
      data = []
      data_rows = rows[2..]

      headers = perceptible_header_cells.map { |c| join_text(c).downcase }
      if headers.any?(&:empty?)
        @error = 'Headers must not be empty'
        return nil
      end

      unless data_rows.all? { |r| r.perceptible_cells.length == perceptible_header_cells.length }
        @error = 'All data rows must have the same number of cells as the header row'
        return nil
      end

      data_rows.each do |row|
        entry = {}
        headers.each_with_index do |header, idx|
          entry[header] = Elements::Body.with_renderers(renderers, children: row.perceptible_cells[idx].children.dup)
        end

        next if entry.values.all? { |c| all_text?(c) && join_text(c).empty? }

        data << entry
      end

      data
    end

    def all_text?(cell)
      cell.children.all? do |e|
        e.is_a?(Elements::Paragraph) && e.children.all? { |t| t.is_a?(Elements::Text) }
      end
    end

    def join_text(cell)
      cell.children.map { |p| p.children.map(&:value) }.flatten.join.strip
    end
  end
end
