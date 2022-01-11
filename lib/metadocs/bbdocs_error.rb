module Metadocs
  class BbdocsError < Error
    attr_reader :cause, :source

    def initialize(parslet_error, source)
      @cause = parslet_error
      @source = source
      super(human_friendy_parset_error)
    end

    protected

    def human_friendy_parset_error
      relevant_source = source[cause.parse_failure_cause.pos.charpos..-1].gsub("\n", "\\n")
      "Something went wrong when parsing: `#{relevant_source}`. Please check the source for unbalanced or malformed tags."
    end
  end
end
