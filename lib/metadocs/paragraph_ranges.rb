# frozen_string_literal: true

require 'set'

module Metadocs
  class ParagraphRanges
    attr_reader :source_map

    def initialize(source_map)
      @source_map = source_map
      @ranges = {}
      build_ranges
    end

    def find_paragraph(element, col)
      element_ranges = @ranges[element]
      return nil unless element_ranges

      element_ranges.each do |(range, structural_element, paragraph_element)|
        return [structural_element, paragraph_element] if range.member?(col)
      end
    end

    def find_paragraphs(element, col, text)
      element_ranges = @ranges[element]
      return [] unless element_ranges

      paragraphs = []
      element_ranges.each do |(range, structural_element, paragraph_element)|
        break if text.nil? || text.empty?

        next unless range.member?(col)

        found_char_len = range.end - col
        found_text = text[0...found_char_len]
        text = text[found_char_len..]
        col += found_char_len
        paragraphs << [structural_element, paragraph_element, found_text]
      end

      paragraphs
    end

    protected

    def build_ranges
      source_map.each do |_uuid, mapping|
        next unless mapping.paragraph_element

        @ranges[mapping.element] ||= Set.new
        @ranges[mapping.element].add([
                                       mapping.source_location,
                                       mapping.structural_element,
                                       mapping.paragraph_element
                                     ])
      end
    end
  end
end
