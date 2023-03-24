# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Image < Elements::Element
      attr_accessor :id, :content_uri, :source_uri, :link_uri, :title, :description, :width, :height, :is_drawing, :is_cropped

      def initialize(id: nil, content_uri: nil, source_uri: nil, link_uri: nil, title: nil, description: nil, width: nil, height: nil, is_drawing: false, is_cropped: false)
        super()
        @id = id
        @content_uri = content_uri
        @source_uri = source_uri
        @link_uri = link_uri
        @title = title
        @description = description
        @width = width
        @height = height
        @is_drawing = is_drawing
        @is_cropped = is_cropped
      end

      def url
        content_uri || source_uri
      end
    end
  end
end
