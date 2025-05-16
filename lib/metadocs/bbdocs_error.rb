module Metadocs
  class BbdocsError < Error
    attr_reader :cause, :source

    def initialize(parslet_error, source)
      @cause = parslet_error
      @source = source
      super(human_friendly_parslet_error)
    end

    protected

    def human_friendly_parslet_error
      error_char_pos = cause.parse_failure_cause.pos&.charpos
      # Handle potential nil position
      return 'Unknown parsing error: Position information unavailable.' unless error_char_pos

      error_line_num = source[0...error_char_pos].count("\n") + 1

      context_start_line = error_line_num - 4
      context_end_line = error_line_num + 4

      all_lines = source.lines
      total_lines = all_lines.count

      context_start_line = [1, context_start_line].max
      context_end_line = [total_lines, context_end_line].min

      # Ensure start <= end even for tiny files
      context_end_line = [context_start_line, context_end_line].max if total_lines.positive?

      # Get the slice of lines (0-indexed slice from 1-indexed lines)
      context_lines = all_lines[(context_start_line - 1)..(context_end_line - 1)]
      context_lines ||= [] # Handle empty source or weird indexing

      # Number the lines and add a pointer to the error line
      max_line_num_width = context_end_line.to_s.length
      numbered_source = context_lines.map.with_index(context_start_line) do |line, num|
        prefix = num == error_line_num ? ' -> ' : '    ' # Pointer for the error line
        # Pad line numbers for alignment based on the max line number in the context
        "#{prefix}#{num.to_s.rjust(max_line_num_width)}: #{line.chomp}"
      end.join("\n") # Join with newlines explicitly

      # Original parslet message
      parslet_cause_message = cause.parse_failure_cause.message

      "Parse error: #{parslet_cause_message} near line #{error_line_num}\n\nContext:\n#{numbered_source}\n\nPlease check the source for unbalanced or malformed tags."
    end
  end
end
