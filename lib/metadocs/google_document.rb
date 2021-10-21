# frozen_string_literal: true

require 'google/apis/docs_v1'

module Metadocs
  class GoogleDocument
    REQUIRED_SCOPES = ['https://www.googleapis.com/auth/documents'].freeze

    attr_reader :authorization, :docs_service, :document_id

    def initialize(authorization, document_id)
      @authorization = authorization
      document_id = document_id.split('/d/')[1].split('/')[0] if document_id.start_with?('https://')
      @document_id = document_id
      @docs_service = Google::Apis::DocsV1::DocsService.new
      @docs_service.authorization = @authorization
    end

    def document
      @document ||= @docs_service.get_document(document_id)
    end
  end
end
