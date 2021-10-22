# Metadocs Tables

Metadocs Tables are special tables that, when declared, are used by Metadocs to gather structured
data. In order to create a Metadocs Table, insert a table in a document, format it according to the
instructions below, and declare the table's title to the parser.

The parser will expose the table's data using Ruby arrays, hashes, and Metadocs elements. A table's
key or column in the metadata hash will always be a string. However, the value for the key/column
will be a `Metadocs::Elements::Body` object with a parse tree. Any kind of Google Docs content can
be stored in the key/column value.

Multiple tables of the same name/type can appear in the same document. Therefore, each declared
table's title will yield a collection of metadata tables.

```ruby
metadoc = Metadocs::Parser.parse(
  google_credentials,
  doc_id,
  metadata_tables: [{ name: 'my-doc-metadata', type: 'key_value', keys: [{ name: 'key-1' }] }]
)

my_doc_metadatas = metadoc['my-doc-metadata']
my_doc_metadatas.count       # May be more than 1
my_doc_metadatas[0]['key-1'] # Access the first my-doc-metadata table found in the document
```

## Table format: title

The first row of a Metadata Table is the title row. The first cell in the title row is read as the
title (spaces are stripped out). If the title was declared to the parser, the parser will then
attempt to parse the table as a Metadata Table. The remaining cells in the title row are
disregarded. If the title has not been declared, Metadocs will treat the table as a normal Google
Docs table.

## Table format: body

There are two types of Metadocs Tables, `key_value` and `tuple`.

### Key-value Tables

Key-value tables must have two columns, one for the key and one for the value. They are a tabular
representation of a hash table/dictionary.

Google Docs example:

Ruby representation:

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

my_doc_metadata = metadoc['my-doc-metadata'][0] # Access the first my-doc-metadata table
my_doc_metadata['key-1'] # => [Elements::Paragraph, Elements::Paragraph...]
my_doc_metadata['key-2'] # => [Elements::Paragraph, Elements::Paragraph...]
```

### Tuple Tables

Tuple tables are similar to RDBMS tables where each row is an entry with separate values that
correspond to a set of columns.

The second row of a tuple table is the header row. Each cell in the header row is read as a column
header for the table data. From the third row on, each row is read as an entry row, and the cell
values are associated with their corresponding header rows. Therefore, tuple tables must have at
least 3 rows.

Google Docs example:

Ruby representation:

```ruby
metadoc = Metadocs::Parser.parse(
  google_credentials,
  doc_id,
  metadata_tables: [
    {
      name: 'my-doc-metadata',
      type: :tuple,
      columns: [
        { name: 'key-1' },
        { name: 'key-2' }
      ]
    }
  ]
)

my_doc_metadata = metadoc['my-doc-metadata'][0] # Access the first my-doc-metadata table
my_doc_metadata.each do |metadata_entry|
  metadata_entry['key-1'] # => [Elements::Paragraph, Elements::Paragraph...]
  metadata_entry['key-2'] # => [Elements::Paragraph, Elements::Paragraph...]
end
```
