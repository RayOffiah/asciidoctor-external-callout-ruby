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
    document = Asciidoctor.convert_file File.join(File.dirname(__FILE__), 'sample.adoc'),
                                        safe: :unsafe, backend: :html5,
                                        attributes: {'stylesheet' => './callout.css'}
    assert document.instance_of? Document
    assert_equal 5, document.blocks.length
    assert_equal document.blocks[1].context, :paragraph
    assert_equal 4, document.blocks[4].items.length
    assert_equal 'The `use_dsl` line', document.blocks[4].items[0].instance_variable_get(:@text)
    assert_equal true, document.blocks[4].has_role?('external-callout-list')
  end

  def test_callout_marker
    document = Asciidoctor.convert_file File.join(File.dirname(__FILE__), 'sample.adoc'),
                                        safe: :unsafe, backend: :html5,
                                        attributes: {'stylesheet' => './callout.css'}

    assert document.blocks[0].context == :listing
    assert document.blocks[0].lines.length == 30
    assert document.blocks[0].lines[2].include? 'use_dsl <1>'
  end

  def test_global_search

    document = Asciidoctor.convert_file File.join(File.dirname(__FILE__), 'sample_global_search.adoc'),
                                        safe: :unsafe, backend: :html5,
                                        attributes: {'stylesheet' => './callout.css'}

    assert document.blocks[0].context == :listing
    assert document.blocks[0].lines.length == 30

    # Every line that contains that contains the phrase 'src' should also
    # contain a callout marker.
    document.blocks[0].lines.each do |line|

      if line.include? 'src'
        assert_equal true, line.include?('<3>')
      end
    end

  end

  def test_case_insensitive_search

    document = Asciidoctor.convert_file File.join(File.dirname(__FILE__), 'sample_global_search.adoc'),
                                        safe: :unsafe, backend: :html5,
                                        attributes: {'stylesheet' => './callout.css'}

    assert document.blocks[0].context == :listing
    assert document.blocks[0].lines.length == 30

    # We should be doing a case-insensitive match for all occurrences of Stdin
    document.blocks[0].lines.each do |line|

      if line.include? 'stdin'
        assert_equal true, line.include?('<4>')
      end
    end


  end

end

