# frozen_string_literal: true

require_relative 'element'

module Metadocs
  module Elements
    class Image < Elements::Element
      attr_accessor :inline_object_id, :content_uri, :source_uri, :title, :description

      def initialize(parser,
                     inline_object_id: nil, content_uri: nil, source_uri: nil, title: nil, description: nil)
        super(parser)
        @inline_object_id = inline_object_id
        @content_uri = content_uri
        @source_uri = source_uri
        @title = title
        @description = description
      end

      def url
        content_uri || source_uri
      end

      def to_h
        super.merge(
          inline_object_id: inline_object_id,
          content_uri: content_uri,
          source_uri: source_uri,
          title: title,
          description: description,
          url: url
        )
      end
    end
  end
end
