# frozen_string_literal: true

require_relative 'element_renderer'

module Metadocs
  class Renderer
    attr_reader :renderer_id, :document

    def initialize(renderer_id, document)
      @renderer_id = renderer_id
      @document = document
    end

    def self.element_renderer(&blk)
      @element_renderer_class = Class.new(ElementRenderer, &blk)
    end

    def self.element_renderer_class
      @element_renderer_class
    end

    def element_renderer(element)
      self.class::element_renderer_class.new(renderer_id, element)
    end

    def render(body_element, render_options = {})
      body_element.render(renderer_id)
    end
  end
end
