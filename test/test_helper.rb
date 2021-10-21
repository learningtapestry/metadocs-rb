# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'metadocs'

require 'minitest/autorun'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'byebug'

GOOGLE_CREDENTIALS_PATH = ENV.fetch(
  'GOOGLE_CREDENTIALS_PATH',
  File.expand_path('../client_secrets.json', __dir__)
)
GOOGLE_STORAGE_PATH = ENV.fetch('GOOGLE_STORAGE_PATH', File.expand_path('../tokens.yaml', __dir__))

def google_authorization
  client_id = Google::Auth::ClientId.from_file(GOOGLE_CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: GOOGLE_STORAGE_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id,
    Metadocs::GoogleDocument::REQUIRED_SCOPES,
    token_store
  )
  authorizer.get_credentials('default')
end
