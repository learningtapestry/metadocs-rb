# frozen_string_literal: true

require_relative 'renderer'

module Metadocs
  class HtmlRenderer < Renderer
    protected

    def render_body
      "<div>#{render_children}</div>".gsub(/\s+/, ' ')
    end

    def render_image
      %(<img id="#{element.id}" src="#{element.url}" />)
    end

    def render_key_value_table
      rows = element.metadata.map do |k, v|
        "<tr><td>#{k}</td><td>#{v.render(type)}</td></tr>"
      end
      "<table><tbody>#{rows.join}</tbody></table>"
    end

    def render_list_item
      %(<div class="list-item">#{render_children.strip}</div>)
    end

    def render_paragraph
      %(<div class="paragraph">#{render_children.strip}</div>)
    end

    def render_table
      "<table><tbody>#{render_all(element.rows).join}</tbody></table>"
    end

    def render_table_row
      "<tr>#{render_all(element.cells).join}</tr>"
    end

    def render_table_cell
      "<td>#{render_children}</td>"
    end

    def render_tag
      %(<div data-tag="#{element.name}">#{render_children}</div>)
    end

    def render_tuple_table
      thead = element.header_cells.map { |h| h.render(type) }.join
      rows = element.metadata.map do |entry|
        tds = entry.map { |_k_, v| "<td>#{v.render(type)}</td>" }.join
        "<tr>#{tds}</tr>"
      end.join
      "<table><thead><tr>#{thead}</tr></thead><tbody>#{rows}</tbody></table>"
    end

    def render_text
      class_names = %i(bold italic underline strikethrough).select do |style|
        element.send(:"#{style}?")
      end
      if class_names.empty?
        element.value
      else
        %(<span class="#{class_names.join(' ')}">#{element.value}</span>)
      end
    end
  end
end
