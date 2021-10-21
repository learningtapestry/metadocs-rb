# frozen_string_literal: true

module Metadocs
  module Elements
  end
end

Dir[File.join(__dir__, 'elements', '*.rb')].sort.each { |file| require file }
