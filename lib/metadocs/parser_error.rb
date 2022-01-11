module Metadocs
  class ParserError < Error
    attr_reader :cause

    def initialize(cause)
      @cause = cause
      super(cause.message)
    end
  end
end
