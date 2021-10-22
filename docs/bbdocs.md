# BBDocs

BBDocs is a templating language that can be freely used within the body of Google Documents. The
syntax is reminiscent of [BBCode](https://en.wikipedia.org/wiki/BBCode). It is designed to be easy
to use by content authors, who are not necessarily tech-savvy.

BBDocs tags are useful for adding context to content sections in documents, or for annotating
documents in various ways. They can be used for stylistic purposes in code that exports documents
to another format, for example.

## Normal Tags

BBDocs normal tags may have child elements (they can be used to wrap content).

```
[special]
This section is considered special...
[/special]
```

## Empty tags

Empty tags are meant to be used without any content inside them. They don't need to be closed.

```
This section is separated from the next with a special separator.
[special_separator]
This section is separated from the previous with a special separator.
```

## Attributes

Tags may have attributes. For example, a `drawing_area` tag with attributes `size` and `background`:

```
[drawing_area size="large" background="red"]
```

## Qualifiers

Qualifiers are strings that add one small piece of information to a tag. They are meant for simple
use cases where attributes are unnecessary. For example, a `drawing_area` tag with qualifier
`large`:

```
[drawing_area:large]
```

## Malformed content

The Metadocs parser will fail to parse when encountering things like unbalanced tags (normal tags
that lack a closing tag). However, it is tolerant to inconsistent space usage.

```
# This will parse, assuming `drawing_area` is defined as an empty tag.
[drawing_area
size="large"
  background="red"
]

# With the document ending at <EOF> and `[special]` defined as a normal tag, this will result in a
# parser error, as the tag is unbalanced.
[special]
This section is considered special...
<EOF>

```

## Usage in Metadocs

BBDocs tags are declared to the parser using the `tags` and `empty_tags` parameters. The tags
and their contents will be available in the parse tree:

```ruby
metadoc = Metadocs::Parser.parse(
  google_credentials,
  doc_id,
  tags: [{ name: 'special', attributes: ['a', 'b'] }],
  empty_tags: [{ name: 'drawing_area', attributes: ['size', 'background'] }]
)

metadoc.each do |element|
  if element.tag?
    puts [element.name, element.attributes, element.qualifier]
    # => 'special',
    # => { a: 'example', b, ... }
    # => 'large'

    element.each do |child_element|
      # Handle content nested inside the tag
    end
  end
end
```

## Validation

Note that at the moment no validation is done to attributes and qualifiers. However, it is a
planned feature.
