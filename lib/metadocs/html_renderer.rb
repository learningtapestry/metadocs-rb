# frozen_string_literal: true

require_relative 'renderer'

module Metadocs
  class HtmlRenderer < Renderer
    def initialize(type, element, parser_options = {})
      super
      return unless parser_options[:prettify]

      require 'htmlbeautifier'
    end

    protected

    def render_body
      rendered = if @parser_options[:root]
                   <<~HTML
                     <!DOCTYPE html>
                     <html>
                       <body>
                         #{render_children}
                       </body>
                     </html>
                   HTML
                 else
                   render_children
                 end

      if @parser_options[:prettify]
        HtmlBeautifier.beautify(rendered).encode('utf-8')
      else
        rendered
      end
    end

    def render_image
      %(<img data-inline-object-id="#{element.inline_object_id}" src="#{element.url}" />)
    end

    def render_key_value_table
      rows = metadata_element.metadata.map do |k, v|
        "<tr><td>#{k}</td><td>#{v.render(type)}</td></tr>"
      end
      "<table><tbody>#{rows.join}</tbody></table>"
    end

    def render_paragraph
      rendered_children = render_children.strip
      return if rendered_children.empty?

      %(<div data-type="p">#{rendered_children}</div>)
    end

    def render_table
      rendered_rows = render_all(element.rows).join

      "<table><tbody>#{rendered_rows}</tbody></table>"
    end

    def render_table_row
      rendered_cells = render_all(element.cells).join

      "<tr>#{rendered_cells}</tr>"
    end

    def render_table_cell
      rendered_children = render_children.strip

      "<td>#{rendered_children}</td>"
    end

    def render_tag
      qualifier = element.qualifier&.strip
      qualifier = qualifier && !qualifier.empty? ? " data-qualifier=\"#{qualifier}\"" : nil
      attributes = element.attributes.to_a.map { |(k, v)| "data-attribute-#{k}=\"#{v}\"" }.join(' ').strip
      attributes = attributes && !attributes.empty? ? " #{attributes}" : nil

      if element.empty?
        %(<div data-tag="#{element.name}"#{attributes}#{qualifier}></div>)
      else
        %(<div data-tag="#{element.name}"#{attributes}#{qualifier}>#{render_children.strip}</div>)
      end
    end

    def render_tuple_table
      thead = metadata_element.header_cells.map { |h| h.render(type) }.join
      rows = metadata_element.metadata.map do |entry|
        tds = entry.map { |_k_, v| "<td>#{v.render(type)}</td>" }.join
        "<tr>#{tds}</tr>"
      end.join
      "<table><thead><tr>#{thead}</tr></thead><tbody>#{rows}</tbody></table>"
    end

    def render_text
      text_val = element.value.strip
      return if text_val.empty?

      if element.bold?
        text_val = %(<b>#{text_val}</b>)
      end

      if element.italic?
        text_val = %(<i>#{text_val}</i>)
      end

      if element.underline?
        text_val = %(<u>#{text_val}</u>)
      end

      if element.strikethrough?
        text_val = %(<s>#{text_val}</s>)
      end

      text_val
    end
  end
end
