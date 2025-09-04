# frozen_string_literal: true

require 'parslet'
require_relative 'bbdocs_error'

module Metadocs
  class Bbdocs
    attr_reader :tags, :empty_tags, :ignore_tags, :parser

    TAG_RE = /[\[\]]/.freeze
    BUILTIN_TAGS = %w(gdocs).freeze
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
    rescue Parslet::ParseFailed => e
      raise BbdocsError.new(e, content)
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
        def stri(str)
          str.chars
            .map! do |char|
              if char.match(/[a-zA-Z]/)
                match["#{char.upcase}#{char.downcase}"]
              else
                str(char)
              end
            end
            .reduce(:>>)
        end

        root(:node)

        rule(:node) do
          (
            tag.as(:tag) |
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
          (ignore_tag | escaped_special | unknown_bracket | (text_special.absent? >> any)).repeat(1)
        end

        rule(:user_defined_tag) do
          self.class::TAGS.map { |t| stri(t) }.reduce(:|)
        end

        rule(:ignore_tag) do
          str('[') >>
            space? >>
            self.class::IGNORE_TAGS.map { |t| stri(t) }.reduce(:|).as(:name) >>
            qualifier.maybe >>
            (space >> attribute).repeat.as(:attributes) >>
            space? >>
            str(']')
        end

        rule(:unknown_bracket) do
          tag_defs = [
            str('$:'),                                # reference
            (space? >> str('/') >> user_defined_tag), # end tag
            user_defined_tag                          # start or self-closing
          ]
          unless self.class::EMPTY_TAGS.empty?
            tag_defs << (
              space? >>
              self.class::EMPTY_TAGS
                .map { |t| stri(t) }.reduce(:|)
            )
          end
          str('[') >> tag_defs.reduce(:|).absent? >>
          (str(']').absent? >> any).repeat >> str(']').maybe
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
            str('[') >>
            space? >>
            str('/') >>
            user_defined_tag.as(:name) >>
            space? >>
            str(']')
          )
        end

        rule(:childless_tag) do
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
            self.class::EMPTY_TAGS.map { |t| stri(t) }.reduce(:|).as(:name) >>
            qualifier.maybe >>
            (space >> attribute).repeat.as(:attributes) >>
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
            childless_tag,
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
            (str('"') >> double_quoted_attribute_value.as(:value) >> str('"')) |
            (str("'") >> single_quoted_attribute_value.as(:value) >> str("'")) |
            (str('’') >> single_curly_attribute_value.as(:value) >> str('’')) |
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

        rule(:single_curly_attribute_value) do
          (str('’').absent? >> (match(/[^\[]/) | string_entity | numeric_entity)).repeat
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
          ((space >> name >> str('=')).absent? >> match(/[\w\s\-,\.]/)).repeat(1)
        end

        rule(:string_entity) { match('&') >> name >> match(';') }
        rule(:numeric_entity) { match(/&#\d+;/) }

        rule(:space)  { match(/\s/).repeat(1) }
        rule(:space?) { space.maybe }
      end
    end
  end
end
