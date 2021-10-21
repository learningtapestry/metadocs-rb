# frozen_string_literal: true

require 'parslet'

module Metadocs
  class Bbdocs
    attr_reader :tags, :empty_tags, :ignore_tags, :parser

    TAG_RE = /[\[\]]/.freeze
    BUILTIN_TAGS = %w(gdocs equation).freeze
    BUILTIN_EMPTY_TAGS = [].freeze
    BUILTIN_IGNORE_TAGS = ['noop'].freeze

    def initialize(tags: [], empty_tags: [], ignore_tags: [])
      all_user_tags = tags + empty_tags + ignore_tags
      all_builtins = BUILTIN_TAGS + BUILTIN_EMPTY_TAGS + BUILTIN_IGNORE_TAGS
      overlap = all_user_tags & all_builtins

      raise ArgumentError, '$ is a reserved value' if all_user_tags.any? { |t| t.start_with?('$') }
      raise ArgumentError, "#{overlap.join(', ')} are reserved values" if overlap.any?

      @tags = tags
      @empty_tags = empty_tags
      @ignore_tags = ignore_tags
      @parser = generate_parser
    end

    def parse(content)
      parser.new.parse(content)
    end

    protected

    def generate_parser
      custom_parser = new_parser_class
      custom_parser.const_set('TAGS', BUILTIN_TAGS + tags)
      custom_parser.const_set('EMPTY_TAGS', BUILTIN_EMPTY_TAGS + empty_tags)
      custom_parser.const_set('IGNORE_TAGS', BUILTIN_IGNORE_TAGS + ignore_tags)
      custom_parser
    end

    def new_parser_class
      Class.new(Parslet::Parser) do
        root(:node)

        rule(:node) do
          (
            (blank_tag | tag).as(:tag) |
            text.as(:text) |
            reference.as(:reference)
          ).repeat(0)
        end

        rule(:reference) do
          str('[$:') >>
            match(/\w/).repeat.as(:value) >>
            str(']')
        end

        rule(:text_special) { match(/[\[\]]/) }

        rule(:escaped_special) { str('\\') >> match(/[\[\]]/) }

        rule(:text) do
          (ignore_tag | escaped_special | (text_special.absent? >> any)).repeat(1)
        end

        rule(:user_defined_tag) do
          self.class::TAGS.map { |t| str(t) }.reduce(:|)
        end

        rule(:ignore_tag) do
          str('[') >>
            self.class::IGNORE_TAGS.map { |t| str(t) }.reduce(:|) >>
            space? >>
            str(']')
        end

        rule(:start_tag) do
          str('[') >>
            user_defined_tag.as(:name) >>
            qualifier.maybe >>
            (space >> attribute).repeat.as(:attributes) >>
            space? >>
            str(']')
        end

        rule(:end_tag) do
          (
            str('[/') >>
            user_defined_tag.as(:name) >>
            space? >>
            str(']')
          )
        end

        rule(:blank_tag) do
          start_tag.as(:start_tag) >>
            match(/\s+/) >>
            end_tag.as(:end_tag)
        end

        rule(:empty_tag) do
          str('[') >>
            user_defined_tag.as(:name) >>
            (space >> attribute).repeat.as(:attributes) >>
            space? >>
            str('/]')
        end

        rule(:empty_user_defined_tag) do
          str('[') >>
            space? >>
            self.class::EMPTY_TAGS.map { |t| str(t) }.reduce(:|).as(:name) >>
            qualifier.maybe >>
            space? >>
            str(']')
        end

        rule(:tag) do
          rules = [
            (
              start_tag.as(:start_tag) >>
              node.as(:children) >>
              end_tag.as(:end_tag)
            ),
            empty_tag.as(:empty_tag)
          ]
          rules.unshift(empty_user_defined_tag.as(:empty_tag)) unless self.class::EMPTY_TAGS.empty?
          rules.reduce(:|)
        end

        rule(:name) do
          match(/[a-zA-Z_]/) >> match(/\w/).repeat
        end

        rule(:attribute) do
          name.as(:name) >>
            str('=') >> (
            (str('"') >> double_quoted_attribute_value.as(:value) >> str('"')) | # double quotes
            (str("'") >> single_quoted_attribute_value.as(:value) >> str("'")) | # single quotes
            (str('“') >> left_curly_attribute_value.as(:value) >> str('“')) |
            (str('”') >> right_curly_attribute_value.as(:value) >> str('”'))
          )
        end

        rule(:double_quoted_attribute_value) do
          (str('"').absent? >> (match(/[^\[]/) | string_entity | numeric_entity)).repeat
        end

        rule(:single_quoted_attribute_value) do
          (str("'").absent? >> (match(/[^\[]/) | string_entity | numeric_entity)).repeat
        end

        rule(:left_curly_attribute_value) do
          (str('“').absent? >> (match(/[^\[]/) | string_entity | numeric_entity)).repeat
        end

        rule(:right_curly_attribute_value) do
          (str('”').absent? >> (match(/[^\[]/) | string_entity | numeric_entity)).repeat
        end

        rule(:qualifier) do
          str(':') >>
            space? >>
            qualifier_value.as(:qualifier)
        end

        rule(:qualifier_value) do
          match(/[\w_\-,]/).repeat
        end

        rule(:string_entity) { match('&') >> name >> match(';') }
        rule(:numeric_entity) { match(/&#\d+;/) }

        rule(:space)  { match(/\s/).repeat(1) }
        rule(:space?) { space.maybe }
      end
    end
  end
end
