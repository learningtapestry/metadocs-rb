# frozen_string_literal: true

module Metadocs
  class ParserError < Error
    attr_reader :cause

    def initialize(message, cause)
      super(message)
      @cause = cause
      set_backtrace(cause.backtrace)
    end
  end
end
