require 'minitest/autorun'
require 'asciidoctor-external-callout'
require 'asciidoctor'

class AsciiDoctorExternalCalloutTest < Minitest::Test
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_basic_conversion
    document = Asciidoctor.convert_file File.join(File.dirname(__FILE__), 'sample.adoc'), safe: :unsafe, backend: :html5
    assert document.instance_of? Document
    assert_equal 5, document.blocks.length
    assert_equal document.blocks[1].context, :paragraph
    assert_equal 4, document.blocks[4].items.length
    assert_equal 'The `use_dsl` line', document.blocks[4].items[0].instance_variable_get(:@text)
  end

  def test_callout_marker
    document = Asciidoctor.convert_file File.join(File.dirname(__FILE__), 'sample.adoc'), safe: :unsafe, backend: :html5
    assert document.blocks[0].context == :listing
    assert document.blocks[0].lines.length == 30
    assert document.blocks[0].lines[2].include? 'use_dsl <1>'
  end
end

