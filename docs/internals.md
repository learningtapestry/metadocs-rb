# Notes about Metadocs internals

## Parsing

Metadocs constructs its element tree in a multiple step process:

1. A textual representation of the document is created where each non-text element is replaced by
   a reference. A separate data structure is created that keeps track of which paragraph elements
   correspond to each character in the representation. The purpose of this representation is to allow
   the BBDocs parser to work with the document.

2. The BBDocs source tree is transformed into a Metadocs elements tree. Tags are replaced by `Tag`
   elements, text is replaced by `Paragraph` and `Text` elements, and references are resolved. When
   references are elements with inner content (such as table cells), the same process above is
   repeated for the content inside those elements, allowing BBDocs to be used anywhere in the
   document.

3. The elements tree is balanced so `Tag` elements reside inside `Paragraph` elements when
   appropriate. Because of the way the source tree is constructed, the first pass results in a tree
   where the tags don't connect to paragraphs.

## BBDocs

The BBDocs parser is implemented as a [Parslet](https://kschiess.github.io/parslet/get-started.html)
parser. `Metadocs::Bbdocs` actually generates a new parser customized for the tags declared by the
library user when working with `Metadocs::Parser`.
