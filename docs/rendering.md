# Rendering document content

Every [element](elements.md) in the parse tree returned by a Metadocs parser can be rendered by
calling the `#render` method of the element. For elements that have children, such as the root
`Body` element in the tree or a `Table` element, the children will be recursively rendered starting
from the root.

Renderers are configured when constructing the Metadocs parser. They can then be invoked by name
when calling `#render`. A `:text` and a `:html` renderer are provided by default, but custom
renderers can be configured.

```ruby
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

## Custom renderers

Custom renderers can inherit from the base `Metadocs::Renderer` class or one of the built-in
`Metadocs::TextRenderer` and `Metadocs::HtmlRenderer`.

It is possible to selectively modify the behavior of renderers by overriding specific methods for
rendered elements. The main `#render` method will delegate to specific protected methods such as
`#render_paragraph` and `#render_image`. For tags, there is a `#render_tag` method that also tries
to delegate to `#render_<tag>` if an appropriately named method is defined.

Inside a renderer, the element that is being rendered is accessed by `#element`. Additionally, some
helper methods are available such as `render_children` (renders all the children). See the code for
`Metadocs::Renderer` for more details.

```ruby
class CustomHtmlRenderer < Metadocs::HtmlRenderer
  protected

  def render_paragraph
    # You only need to override the methods you want to customize
    "<p>" + render_children + "</p>"
  end

  def render_blink
    # Render a custom tag
    "<blink>" + render_children + "</blink>"
  end
end
```
