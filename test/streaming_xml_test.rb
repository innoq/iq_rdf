$LOAD_PATH << File.dirname(__FILE__)

require 'test_helper'
require 'stringio'

class StreamingXmlTest < Minitest::Test

  def stream(default_namespace: 'http://www.test.de/', lang: nil, &block)
    io = StringIO.new
    IqRdf::Document.stream(io, :xml, default_namespace: default_namespace, lang: lang, &block)
    io.string
  end

  def test_basic_xml_output
    result = stream(lang: :de) do |doc|
      doc.namespaces foaf: 'http://xmlns.com/foaf/0.1/'
      doc << IqRdf::testemann do |t|
        t.Foaf::knows(IqRdf::testefrau)
        t.Foaf.nick("Testy")
        t.Foaf.lastname("Testemann", :lang => :none)
      end
    end

    assert_match(<<rdf, result)
  <rdf:Description rdf:about="http://www.test.de/testemann">
    <foaf:knows rdf:resource="http://www.test.de/testefrau"/>
    <foaf:nick>Testy</foaf:nick>
    <foaf:lastname xml:lang="">Testemann</foaf:lastname>
  </rdf:Description>
rdf
    assert_match(%r{<rdf:RDF}, result)
    assert_match(%r{</rdf:RDF>}, result)
  end

  def test_document_has_xml_declaration
    result = stream do |doc|
      doc << IqRdf::testemann.title("hello")
    end

    assert result.start_with?("<?xml"), "should start with XML declaration"
  end

  def test_close_writes_footer
    io = StringIO.new
    IqRdf::Document.stream(io, :xml, default_namespace: 'http://www.test.de/') do |doc|
      doc << IqRdf::testemann.title("hello")
    end
    assert_match(%r{</rdf:RDF>}, io.string)
  end

  def test_blank_nodes
    result = stream do |doc|
      doc << IqRdf::testnode.test32 do |blank_node|
        blank_node.title("dies ist ein test")
        blank_node.sub do |subnode|
          subnode.title("blubb")
        end
      end
    end

    assert_match(<<rdf, result)
  <rdf:Description rdf:about="http://www.test.de/testnode">
    <test32>
      <rdf:Description>
        <title>dies ist ein test</title>
        <sub>
          <rdf:Description>
            <title>blubb</title>
          </rdf:Description>
        </sub>
      </rdf:Description>
    </test32>
  </rdf:Description>
rdf
  end

  def test_matches_document_output
    nodes = lambda do |doc|
      doc.namespaces foaf: 'http://xmlns.com/foaf/0.1/'
      doc << IqRdf::testemann do |t|
        t.Foaf::knows(IqRdf::testefrau)
        t.Foaf.nick("Testy")
        t.Foaf.lastname("Testemann", :lang => :none)
      end
    end

    document = IqRdf::Document.new('http://www.test.de/', :lang => :de)
    nodes.call(document)

    result = stream(lang: :de) { |doc| nodes.call(doc) }

    assert_match(%r{<rdf:Description rdf:about="http://www.test.de/testemann">}, result)
    assert_match(%r{<foaf:knows rdf:resource="http://www.test.de/testefrau"/>}, result)
  end

  def test_nil_node_is_ignored
    result = stream { |doc| doc << nil }
    assert_equal "", result
  end

end
