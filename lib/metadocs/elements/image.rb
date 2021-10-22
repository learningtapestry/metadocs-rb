# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Image < Elements::Element
      attr_accessor :id, :content_uri, :source_uri, :title, :description

      def initialize(id: nil, content_uri: nil, source_uri: nil, title: nil, description: nil)
        super()
        @id = id
        @content_uri = content_uri
        @source_uri = source_uri
        @title = title
        @description = description
      end

      def url
        content_uri || source_uri
      end
    end
  end
end
