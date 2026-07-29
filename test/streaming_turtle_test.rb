$LOAD_PATH << File.dirname(__FILE__)

require 'test_helper'
require 'stringio'

class StreamingTurtleTest < Minitest::Test

  def stream(default_namespace: 'http://www.test.de/', lang: nil, config: {}, &block)
    io = StringIO.new
    IqRdf::Document.stream(io, :ttl,
      default_namespace: default_namespace,
      lang: lang,
      config: config,
      &block)
    io.string
  end

  def test_basic_output
    result = stream(lang: :de) do |doc|
      doc.namespaces foaf: 'http://xmlns.com/foaf/0.1/'
      doc << IqRdf::testemann do |t|
        t.Foaf::knows(IqRdf::testefrau)
        t.Foaf.nick("Testy")
        t.Foaf.lastname("Testemann", :lang => :none)
      end
    end

    assert_equal(<<~RDF, result)
      @prefix : <http://www.test.de/>.
      @prefix foaf: <http://xmlns.com/foaf/0.1/>.
      @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.

      :testemann foaf:knows :testefrau;
                 foaf:nick "Testy"@de;
                 foaf:lastname "Testemann".
    RDF
  end

  def test_matches_document_output
    nodes = lambda do |doc|
      doc.namespaces skos: 'http://www.w3.org/2008/05/skos#', foaf: 'http://xmlns.com/foaf/0.1/', upb: 'http://www.upb.de/'
      doc << IqRdf::testemann.myCustomNote("This is an example", :lang => :en)
      doc << IqRdf::testemann(IqRdf::Foaf::build_uri("Person")).Foaf::name("Heinz Peter Testemann", :lang => :none)
      doc << IqRdf::testemann.Foaf::knows(IqRdf::testefrau)
    end

    document = IqRdf::Document.new('http://www.umweltprobenbank.de/', lang: :de)
    nodes.call(document)
    expected = document.to_turtle

    result = stream(default_namespace: 'http://www.umweltprobenbank.de/', lang: :de) do |doc|
      nodes.call(doc)
    end

    assert_equal expected, result
  end

  def test_config_empty_line_between_triples
    result = stream(config: { empty_line_between_triples: true }) do |doc|
      doc << IqRdf::testemann.myCustomNote("This is an example", :lang => :en)
      doc << IqRdf::testemann.myCustomNote("Zweites Beispiel", :lang => :de)
    end

    assert_equal(<<~RDF, result)
      @prefix : <http://www.test.de/>.
      @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.

      :testemann :myCustomNote "This is an example"@en.

      :testemann :myCustomNote "Zweites Beispiel"@de.

    RDF
  end

  def test_multiple_nodes_written_incrementally
    io = StringIO.new
    IqRdf::Document.stream(io, :ttl, default_namespace: 'http://www.test.de/') do |doc|
      doc << IqRdf::node1.title("First")
      assert_match(/@prefix/, io.string, "header should be written before first node")

      doc << IqRdf::node2.title("Second")
      assert_match(/:node1/, io.string, "first node should be written before second << call")
    end
  end

  def test_nil_node_is_ignored
    result = stream do |doc|
      doc << nil
    end

    assert_equal "", result
  end

end
