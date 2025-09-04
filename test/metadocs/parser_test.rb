# frozen_string_literal: true

require 'test_helper'

class Metadocs::ParserTest < Minitest::Test
  TEST_DOCUMENT_ID = '1HXU25NyKtUc4nlUfs1Yt558pO0CzYXMF8fnrBfbZO9c'
  PARSER_ERROR_DOCUMENT_ID = '1WaIeBtwwutzw6DbJBKaXSTQpRl2Uo7mD_CNQwBCQgQ8'

  def setup
    @google_credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(ENV.fetch('GOOGLE_CREDENTIALS_PATH')),
      scope: ['https://www.googleapis.com/auth/documents']
    )
  end

  def parse_doc(doc_id)
    Metadocs::Parser.parse(
      @google_credentials,
      doc_id,
      metadata_tables: [
        {
          name: '[pet-tuples]',
          type: :tuple,
          keys: [
            { name: 'pet' },
            { name: 'rival' }
          ]
        },
        {
          name: '[pet]',
          type: :key_value,
          keys: [
            { name: 'pet' },
            { name: 'rival' }
          ]
        }
      ],
      empty_tags: [
        { name: 'page-break' },
        { name: 'pet-desc', attributes: %w(name age) }
      ],
      tags: [
        { name: 'pet-full' }
      ]
    )
  end

  def test_each
    doc = parse_doc(TEST_DOCUMENT_ID)

    doc.each do |element|
      assert_kind_of Metadocs::Elements::Element, element
    end
  end

  def test_hash_access
    doc = parse_doc(TEST_DOCUMENT_ID)

    assert_kind_of Metadocs::Elements::Element, doc[0]
    assert_equal 'dog', doc['pet'][0]['pet'].render(:text)
    assert_equal 'cat', doc['pet-tuples'][0][0]['rival'].render(:text)
  end

  def test_render_html
    doc = parse_doc(TEST_DOCUMENT_ID)
    img_url = doc.find(&:image?).url

    expected_html = <<~HTML
      <!DOCTYPE html>
      <html>
        <body>
          <div data-type="p">Test</div>
          <div data-type="p"><b>Test</b></div>
          <div data-type="p"><i>Test</i></div>
          <div data-type="p"><u>Test</u></div>
          <div data-type="p"><s>Test</s></div>
          <div data-type="p"><u><i><b>Test</b></i></u></div>
          <table>
            <tbody>
              <tr>
                <td>pet</td>
                <td>
                  <div data-type="p"><b>dog</b></div>
                </td>
              </tr>
              <tr>
                <td>rival</td>
                <td>
                  <div data-type="p">cat</div>
                </td>
              </tr>
            </tbody>
          </table>
          <table>
            <thead>
              <tr>
                <td>
                  <div data-type="p">pet</div>
                </td>
                <td>
                  <div data-type="p">rival</div>
                </td>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  <div data-type="p">dog</div>
                </td>
                <td>
                  <div data-type="p"><b>cat</b></div>
                </td>
              </tr>
            </tbody>
          </table>
          <div data-type="p">
            <div data-tag="page-break"></div>
          </div>
          <div data-type="p">
            <div data-tag="page-break"></div>
          </div>
          <div data-type="p">[unknown tag with nothing in it]</div>
          <div data-type="p">Test with qualifier…
            <div data-tag="pet-desc" data-qualifier="short with space"></div>
          </div>
          <div data-type="p">Test with attributes…
            <div data-tag="pet-desc" data-attribute-name="bob" data-attribute-age="2" data-qualifier="short"></div>
          </div>
          <div data-type="p">Test with curly (single)…
            <div data-tag="pet-desc" data-attribute-name="bob" data-attribute-age="2"></div>
          </div>
          <div data-type="p">Test with curly (left)…
            <div data-tag="pet-desc" data-attribute-name="bob" data-attribute-age="2"></div>
          </div>
          <div data-type="p">Test with curly (right)…
            <div data-tag="pet-desc" data-attribute-name="bob" data-attribute-age="2"></div>
          </div>
          <div data-type="p">Test with single quote…
            <div data-tag="pet-desc" data-attribute-name="bob" data-attribute-age="2"></div>
          </div>
          <div data-type="p">Test with qualifier and attributes…
            <div data-tag="pet-desc" data-attribute-name="bob" data-attribute-age="2" data-qualifier="short"></div>
          </div>
          <div data-tag="pet-full">
            <div data-type="p">Testing a tag that has child elements.</div>
          </div>
          <img data-inline-object-id="kix.czy47t7vd9c7" src="#{img_url}" />
          <table>
            <tbody>
              <tr>
                <td>
                  <div data-type="p">Test</div>
                </td>
                <td></td>
              </tr>
              <tr>
                <td></td>
                <td></td>
              </tr>
              <tr>
                <td></td>
                <td>
                  <div data-type="p">Test</div>
                </td>
              </tr>
            </tbody>
          </table>
        </body>
      </html>
    HTML

    assert_equal expected_html.chomp, doc.render(:html, prettify: true)
  end

  def test_render_text
    doc = parse_doc(TEST_DOCUMENT_ID)
    img_url = doc.find(&:image?).url

    expected_text = <<~TEXT
      Test
      Test
      Test
      Test
      Test
      Test

      [pet]
      {"pet" => "dog", "rival" => "cat"}

      [pet-tuples]
      [{"pet" => "dog", "rival" => "cat"}]
      [page-break]
      [page-break]
      [unknown tag with nothing in it]

      Test with qualifier… [pet-desc:short with space]

      Test with attributes… [pet-desc:short]

      Test with curly (single)… [pet-desc]

      Test with curly (left)… [pet-desc]

      Test with curly (right)… [pet-desc]

      Test with single quote… [pet-desc]

      Test with qualifier and attributes… [pet-desc:short]

      [pet-full]

      IMG #{img_url}

      Test

      Test
    TEXT

    assert_equal expected_text.chomp, doc.render(:text)
  end

  def test_bbdocs_error
    assert_raises(Metadocs::BbdocsError) do
      parse_doc(PARSER_ERROR_DOCUMENT_ID)
    end
  end
end
