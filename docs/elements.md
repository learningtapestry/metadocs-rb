# Elements tree

When a document is parsed by Metadocs, a tree is constructed with high level abstractions for
Google Docs API document entities. The abstractions aren't necessarily 1:1 - the goal is to provide
an easy to use framework based on Google Docs, not a rewrite of the Docs API client.

Please note that not all Google Documents entities are supported yet. The library is a work in
progress.

## Element types

### Body

The root element for a detached element tree. Appears as the root element for parsed documents as
well as the root element for Metadocs Table key/column values.

### Image

An inline image.

### MetadataTable

A [Metadocs Table](metadata_table.md).

### Paragraph

Content that appears in the same line in a Google Document will appear in the same `Paragraph`,
usually in the form of `Text` elements.

### Table, TableRow, TableCell

Elements used for constructing a `Table`.

### Tag

A [BBDocs](bbdocs.md) tag.

### Text

Text content.

## Iterating through the elements tree

Elements that may have child elements, such as `Body` and `TableCell`, can be iterated with `#each`.
It is possible to check the type of an element with the helper `#<type>?`. Elements have
type-specific helper methods, such as `#bold?` for `Text` elements and `#url` for `Image` elements.

```ruby
metadoc.each do |element|
  if element.paragraph?
    element.each do |child|
      if child.text?
        puts child.value # => 'Hello world!'
      end
    end
  end
end
```

## API Limitations

Unfortunately, not all entities in Google Docs are currently supported by the official API.

More importantly, Equations and Drawings are not fully presented by the API - Equations are an
empty object (the API doesn't give us any information about their values) and Drawings are not
rendered in any way. Therefore, those two entity types are not supported by Metadocs.
