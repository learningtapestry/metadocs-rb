# frozen_string_literal: true

module Metadocs
  class Error < StandardError; end
end

Dir[File.join(__dir__, 'metadocs', '*.rb')].sort.each { |file| require file }
