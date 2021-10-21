# frozen_string_literal: true

module Metadocs
  class Elements::Element
    attr_accessor :renderers, :structural_element

    def self.with_renderers(renderers, attrs = {})
      new_element = new(attrs)
      new_element.renderers = renderers
      new_element
    end

    def render(renderer_type)
      self.render_instances ||= {}
      self.render_instances[renderer_type] ||= renderers[renderer_type].new(renderer_type, self)
      self.render_instances[renderer_type].render
    end

    protected

    attr_accessor :render_instances
  end
end
