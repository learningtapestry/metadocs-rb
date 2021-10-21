# frozen_string_literal: true

Dir[File.join(__dir__, 'metadocs', '*.rb')].sort.each { |file| require file }

module Metadocs
  class Error < StandardError; end
  # Your code goes here...
end
