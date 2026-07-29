# -*- encoding : utf-8 -*-
$LOAD_PATH << File.dirname(__FILE__)

require 'test_helper'
require 'stringio'

class StreamingNTriplesTest < Minitest::Test

  def stream(default_namespace: 'http://www.test.de/', lang: nil, &block)
    io = StringIO.new
    IqRdf::Document.stream(io, :nt, default_namespace: default_namespace, lang: lang, &block)
    io.string
  end

  def test_basics
    result = stream(lang: :de) do |doc|
      doc.namespaces foaf: 'http://xmlns.com/foaf/0.1/'
      doc << IqRdf::testemann do |t|
        t.Foaf::knows(IqRdf::testefrau)
        t.Foaf.nick("Testy")
        t.Foaf.lastname("Testemann", :lang => :none)
      end
    end

    assert_equal(<<~RDF.strip, result.strip)
      <http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/knows> <http://www.test.de/testefrau> .
      <http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/nick> "Testy"@de .
      <http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/lastname> "Testemann" .
    RDF
    assert result.end_with?("\n"), "should end with trailing newline"
  end

  def test_matches_document_output
    nodes = lambda do |doc|
      doc.namespaces skos: 'http://www.w3.org/2008/05/skos#',
                     foaf: 'http://xmlns.com/foaf/0.1/',
                     upb:  'http://www.upb.de/'
      doc << IqRdf::testemann.myCustomNote("This is an example", :lang => :en)
      doc << IqRdf::testemann(IqRdf::Foaf::build_uri("Person")).Foaf::name("Heinz Peter Testemann", :lang => :none)
      doc << IqRdf::testemann.Foaf::knows(IqRdf::testefrau)
      doc << IqRdf::testemann.Foaf::nick("Crash test dummy")
    end

    document = IqRdf::Document.new('http://www.umweltprobenbank.de/', :lang => :de)
    nodes.call(document)
    expected = document.to_ntriples

    result = stream(default_namespace: 'http://www.umweltprobenbank.de/', lang: :de) do |doc|
      nodes.call(doc)
    end

    assert_equal expected, result
  end

  def test_blank_nodes
    result = stream do |doc|
      doc << IqRdf::testnode.test32 do |blank_node|
        blank_node.title("dies ist ein test")
        blank_node.build_predicate(:test, "Another test")
        blank_node.sub do |subnode|
          subnode.title("blubb")
        end
      end
    end

    assert_equal(<<~RDF.strip, result.strip)
      <http://www.test.de/testnode> <http://www.test.de/test32> _:b1 .
      _:b1 <http://www.test.de/title> "dies ist ein test" .
      _:b1 <http://www.test.de/test> "Another test" .
      _:b1 <http://www.test.de/sub> _:b2 .
      _:b2 <http://www.test.de/title> "blubb" .
    RDF
  end

  def test_blank_nodes_numbered_across_nodes
    result = stream do |doc|
      doc << IqRdf::node1.pred1 do |blank_node|
        blank_node.title("first")
      end
      doc << IqRdf::node2.pred2 do |blank_node|
        blank_node.title("second")
      end
    end

    # blank node counter must not reset between << calls:
    # second blank node gets _:b2, not _:b1 again
    assert_match(/_:b2 <.*> "second"/, result)
    refute_match(/_:b1 <.*> "second"/, result)
  end

  def test_collections
    result = stream(default_namespace: 'http://test.de/') do |doc|
      doc << IqRdf::testemann.testIt([IqRdf::hello, IqRdf::goodbye, "bla"])
    end

    assert_match(/<http:\/\/test.de\/testemann> <http:\/\/test.de\/testIt> _:b/, result)
    assert_match(/rdf-syntax-ns#List/, result)
    assert_match(/rdf-syntax-ns#first/, result)
    assert_match(/rdf-syntax-ns#rest/, result)
  end

  def test_nil_node_is_ignored
    result = stream { |doc| doc << nil }
    assert_equal "", result
  end

  def test_no_header_written
    io = StringIO.new
    IqRdf::Document.stream(io, :nt, default_namespace: 'http://www.test.de/') do |doc|
      doc << IqRdf::testemann.title("hello")
    end
    refute_match(/@prefix/, io.string, "NT format should have no @prefix header")
  end

end
