# Metadocs: Content Extraction Tools for Google Docs

Metadocs is a set of tools for extracting data out of Google Documents. It is designed to
to make life easier when using Google Docs as a content source for CMSs and related
applications. It provides three main features:

- A high level, idiomatic [abstraction](docs/elements.md) of
  [Google Docs API entities](https://developers.google.com/docs/api/reference/rest/v1/documents#Document)
- [BBDocs](docs/bbdocs.md), a markup language that can be used inside Google Documents
- [Metadocs Tables](docs/metadocs_tables.md), a specification for storing structured data inside
  Google Documents

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metadocs'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install metadocs

## Usage

Metadocs pulls data from the Google Docs API, so in order to use it you need a [Credentials](https://www.rubydoc.info/github/google/google-auth-library-ruby/Google/Auth/Credentials)
object that is authorized to access the document you're interacting with. Some examples are
available at [API Authentication](docs/api_authentication.md).

The simplest way to use the library is by calling `Metadocs::Parser.parse`:

```ruby
metadoc = Metadocs::Parser.parse(google_credentials, doc_id)
```

`doc_id` can be either the the URL to a Google Document or the ID section in the link.

### Reading content from a document

The object returned by `.parse` can be iterated as a tree structure with objects that wrap Google
Docs entities. There are helper methods you can call such as `.bold?` and `.italic?` for text
paragraphs.

Note that some entities are currently unsupported by the Docs API, and thus will not be available
in Metadocs. See more at [Elements](docs/elements.md).

```ruby
metadoc.each do |element|
  if element.paragraph? && element.first.bold?
    puts element.render(:html) # <div><b>This is bold,</b> this isn't!</div>
  end
end
```

### BBDocs

BBDocs lets you annotate documents with a syntax reminiscent of
[BBCode](https://en.wikipedia.org/wiki/BBCode). For more information, check out the
[BBDocs documentation](docs/bbdocs.md).

BBDocs tag elements also appear in the parse tree:

```ruby
metadoc = Metadocs::Parser.parse(
  google_credentials,
  doc_id,
  tags: [{ name: 'my-tag', attributes: ['a', 'b'] }]
)

metadoc.each do |element|
  if element.tag?
    puts [element.name, element.attributes]
    # => 'my-tag'
    # => { a: 'example', b, ... }

    element.each do |child_element|
      # Handle content nested inside the tag
    end
  end
end
```

### Metadocs Tables

Inline tables conforming to the Metadocs Tables specification will show up as structured data in
the parse result. They're useful for storing metadata inside documents. Learn more about them in
the [Metadocs Tables documentation](docs/metadocs_tables.md).

```ruby
metadoc = Metadocs::Parser.parse(
  google_credentials,
  doc_id,
  metadata_tables: [
    {
      name: 'my-doc-metadata',
      type: :key_value,
      keys: [
        { name: 'key-1' },
        { name: 'key-2' }
      ]
    }
  ]
)

# A doc may have multiple Metadocs Tables with the same name, so they're stored
# as an array.
metadoc['my-doc-metadata'][0]['key-1'] # => [Elements::Paragraph, ...]
```

### Rendering

Every element in the tree can render itself to text and HTML, and it's easy to add custom renderers
to the parser:

```ruby
class CustomHtmlRenderer < Metadocs::HtmlRenderer
  def render_tag
    if element.name == 'blink'
      '<blink>' + render_children + '</blink>' # Why would somebody use this?
    else
      super
    end
  end
end

metadoc = Metadocs::Parser.parse(
  google_credentials,
  doc_id,
  tags: [ { name: 'blink' } ],
  renderers: { custom_html: CustomHtmlRenderer }
)

metadoc.each do |element|
  if element.tag?
    puts element.render(:text)        # => '[blink]This is blinking text![/blink]'
    puts element.render(:html)        # => '<div data-tag="blink">This is blinking text!</div>'
    puts element.render(:custom_html) # => '<blink>This is blinking text!</blink>'
  end
end
```

There is more information about custom renderers in the
[Renderers documentation](docs/rendering.md).

## Development

You can learn more about how Metadocs works internally in the
[Internals documentation](docs/internals.md).

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which
will create a git tag for the version, push git commits and the created tag, and push the `.gem`
file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/learningtapestry/metadocs-rb).
