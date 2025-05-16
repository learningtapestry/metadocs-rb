# frozen_string_literal: true

module Metadocs
  module Elements::ContainerMethods
    def self.included(base)
      base.include Enumerable
      base.attr_accessor :children
    end

    def each(&blk)
      children.each(&blk)
    end

    def [](idx)
      children[idx]
    end
  end
end
