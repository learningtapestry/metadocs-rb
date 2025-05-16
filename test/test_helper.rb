# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'dotenv'
require 'minitest/autorun'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'byebug'
require 'metadocs'

Dotenv.load
