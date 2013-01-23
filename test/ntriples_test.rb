# -*- encoding : utf-8 -*-
#   
#   Copyright 2011 innoQ Deutschland GmbH
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

$LOAD_PATH << File.dirname(__FILE__)

require 'test_helper'

class NTriplesTest < Test::Unit::TestCase

  def test_basics
    document = IqRdf::Document.new('http://example.org/')
    document.namespaces :skos => 'http://www.w3.org/2004/02/skos/core#'
    document << IqRdf.foo do |node|
      node.skos.related(IqRdf.bar)
    end

    assert_equal(<<-rdf.strip, document.to_ntriples.strip)
<http://example.org/foo> <http://www.w3.org/2004/02/skos/core#related> <http://example.org/bar> .
    rdf

    document = IqRdf::Document.new('http://www.test.de/', :lang => :de)
    document.namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

    document << IqRdf::testemann do |t|
      t.Foaf::knows(IqRdf::testefrau)
      t.Foaf.nick("Testy")
      t.Foaf.lastname("Testemann", :lang => :none)
    end

    actual = document.to_ntriples
    assert_equal(<<-rdf.strip, actual.strip)
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/knows> <http://www.test.de/testefrau> .
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/nick> "Testy"@de .
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/lastname> "Testemann" .
    rdf

    assert actual.end_with?("\n"), "trailing line break"
  end

  def test_full_uri_subject
    document = IqRdf::Document.new('http://www.test.de/')

    document << IqRdf::build_full_uri_subject(URI.parse('http://www.xyz.de/#test'),
      IqRdf::build_uri('SomeType')) do |t|
      t.sometest("testvalue")
    end

    assert_equal(<<-rdf.strip, document.to_ntriples.strip)
<http://www.xyz.de/#test> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.test.de/SomeType> .
<http://www.xyz.de/#test> <http://www.test.de/sometest> "testvalue" .
    rdf
  end

  def test_full_uri_predicate
    document = IqRdf::Document.new('http://www.test.de/')

    document << IqRdf::testemann.
        build_full_uri_predicate(URI.parse("http://www.test.org/hoho"), 42)

    assert_equal(<<-rdf.strip, document.to_ntriples.strip)
<http://www.test.de/testemann> <http://www.test.org/hoho> "42"^^<http://www.w3.org/2001/XMLSchema#integer> .
    rdf
  end

  def test_blank_nodes
    document = IqRdf::Document.new('http://www.test.de/')

    document << IqRdf::testnode.test32 do |blank_node|
      blank_node.title("dies ist ein test")
      blank_node.build_predicate(:test, "Another test")
      blank_node.sub do |subnode|
        subnode.title("blubb")
      end
    end

    assert_equal(<<-rdf.strip, document.to_ntriples.strip)
<http://www.test.de/testnode> <http://www.test.de/test32> _:b1 .
_:b1 <http://www.test.de/title> "dies ist ein test" .
_:b1 <http://www.test.de/test> "Another test" .
_:b1 <http://www.test.de/sub> _:b2 .
_:b2 <http://www.test.de/title> "blubb" .
    rdf
  end

  def test_collections
    document = IqRdf::Document.new('http://test.de/')

    document << IqRdf::testemann.testIt([IqRdf::hello, IqRdf::goodbye, "bla"])

    assert_equal(<<-rdf.strip, document.to_ntriples.strip)
_:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#List> .
_:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> <http://test.de/hello> .
_:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b3 .
_:b3 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#List> .
_:b3 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> <http://test.de/goodbye> .
_:b3 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b4 .
_:b4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#List> .
_:b4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "bla" .
<http://test.de/testemann> <http://test.de/testIt> _:b2 .
    rdf
  end

  def test_complex_features
    document = IqRdf::Document.new('http://www.umweltprobenbank.de/', :lang => :de)

    document.namespaces :skos => 'http://www.w3.org/2008/05/skos#',
        :foaf => 'http://xmlns.com/foaf/0.1/', :upb => 'http://www.upb.de/'

    document << IqRdf::testemann.myCustomNote("This is an example", :lang => :en)
    document << IqRdf::testemann(IqRdf::Foaf::build_uri("Person")).
        Foaf::name("Heinz Peter Testemann", :lang => :none)
    document << IqRdf::testemann.Foaf::knows(IqRdf::testefrau)
    document << IqRdf::testemann.Foaf::nick("Crash test dummy")

    ["u1023", "xkfkrl"].each do |id|
      document << IqRdf::Upb::build_uri(id, IqRdf::Skos::build_uri(:Concept)) do |doc|
        doc.Skos::prefLabel("Test", :lang => :en)
        doc.Skos::related(IqRdf::Rdf.anotherThing)

        doc.test1("bla")
        doc.testIt(:hello, :goodbye, "bla")
        doc.anotherTest(URI.parse("http://www.test.de/foo"))

      end
    end

    document << IqRdf::Skos::testnode.test32 do |blank_node|
      blank_node.title("dies ist ein test")
      blank_node.sub do |subnode|
        subnode.title("blubb")
      end
    end

    assert_equal(<<-rdf.strip, document.to_ntriples.strip)
<http://www.umweltprobenbank.de/testemann> <http://www.umweltprobenbank.de/myCustomNote> "This is an example"@en .
<http://www.umweltprobenbank.de/testemann> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
<http://www.umweltprobenbank.de/testemann> <http://xmlns.com/foaf/0.1/name> "Heinz Peter Testemann" .
<http://www.umweltprobenbank.de/testemann> <http://xmlns.com/foaf/0.1/knows> <http://www.umweltprobenbank.de/testefrau> .
<http://www.umweltprobenbank.de/testemann> <http://xmlns.com/foaf/0.1/nick> "Crash test dummy"@de .
<http://www.upb.de/u1023> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.upb.de/u1023> <http://www.w3.org/2008/05/skos#prefLabel> "Test"@en .
<http://www.upb.de/u1023> <http://www.w3.org/2008/05/skos#related> <http://www.w3.org/1999/02/22-rdf-syntax-ns#anotherThing> .
<http://www.upb.de/u1023> <http://www.umweltprobenbank.de/test1> "bla"@de .
<http://www.upb.de/u1023> <http://www.umweltprobenbank.de/testIt> <http://www.umweltprobenbank.de/hello> .
<http://www.upb.de/u1023> <http://www.umweltprobenbank.de/testIt> <http://www.umweltprobenbank.de/goodbye> .
<http://www.upb.de/u1023> <http://www.umweltprobenbank.de/testIt> "bla"@de .
<http://www.upb.de/u1023> <http://www.umweltprobenbank.de/anotherTest> <http://www.test.de/foo> .
<http://www.upb.de/xkfkrl> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos#Concept> .
<http://www.upb.de/xkfkrl> <http://www.w3.org/2008/05/skos#prefLabel> "Test"@en .
<http://www.upb.de/xkfkrl> <http://www.w3.org/2008/05/skos#related> <http://www.w3.org/1999/02/22-rdf-syntax-ns#anotherThing> .
<http://www.upb.de/xkfkrl> <http://www.umweltprobenbank.de/test1> "bla"@de .
<http://www.upb.de/xkfkrl> <http://www.umweltprobenbank.de/testIt> <http://www.umweltprobenbank.de/hello> .
<http://www.upb.de/xkfkrl> <http://www.umweltprobenbank.de/testIt> <http://www.umweltprobenbank.de/goodbye> .
<http://www.upb.de/xkfkrl> <http://www.umweltprobenbank.de/testIt> "bla"@de .
<http://www.upb.de/xkfkrl> <http://www.umweltprobenbank.de/anotherTest> <http://www.test.de/foo> .
<http://www.w3.org/2008/05/skos#testnode> <http://www.umweltprobenbank.de/test32> _:b1 .
_:b1 <http://www.umweltprobenbank.de/title> "dies ist ein test"@de .
_:b1 <http://www.umweltprobenbank.de/sub> _:b2 .
_:b2 <http://www.umweltprobenbank.de/title> "blubb"@de .
    rdf
  end

  def test_literals
    document = IqRdf::Document.new('http://www.test.de/', :lang => :de)
    document.namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

    document << IqRdf::testemann do |t|
      t.Foaf::knows(:testefrau)
      t.Foaf.nick("Testy")
      t.Foaf.lastname("Tästämann", :lang => :none)
      t.age(32)
      t.married(false)
      t.weight(65.8)
      t.complex(IqRdf::Literal.new("A very complex type", :none, URI.parse("http://this.com/is#complex")))
      t.complex2(IqRdf::Literal.new("Shorter form", :none, IqRdf::myDatatype))
      t.quotes("\"I'm \\quoted\"")
      t.line_breaks("I'm written\nover two lines")
      t.some_literal(IqRdf::Literal.new("text", :de))
    end

    assert_equal(<<rdf.strip, document.to_ntriples.strip)
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/knows> <http://www.test.de/testefrau> .
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/nick> "Testy"@de .
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/lastname> "T\\u00e4st\\u00e4mann" .
<http://www.test.de/testemann> <http://www.test.de/age> "32"^^<http://www.w3.org/2001/XMLSchema#integer> .
<http://www.test.de/testemann> <http://www.test.de/married> "false"^^<http://www.w3.org/2001/XMLSchema#boolean> .
<http://www.test.de/testemann> <http://www.test.de/weight> "65.8"^^<http://www.w3.org/2001/XMLSchema#decimal> .
<http://www.test.de/testemann> <http://www.test.de/complex> "A very complex type"^^<http://this.com/is#complex> .
<http://www.test.de/testemann> <http://www.test.de/complex2> "Shorter form"^^<http://www.test.de/myDatatype> .
<http://www.test.de/testemann> <http://www.test.de/quotes> "\\"I'm \\\\quoted\\""@de .
<http://www.test.de/testemann> <http://www.test.de/line_breaks> """I'm written
over two lines"""@de .
<http://www.test.de/testemann> <http://www.test.de/some_literal> "text"@de .
rdf
    end

    def test_supress_if_empty_option
      document = IqRdf::Document.new('http://www.test.de/')
      document.namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

      document << IqRdf::testemann.Foaf::knows(:suppress_if_empty => true)
      document << IqRdf::testemann.Foaf::knows(nil, :suppress_if_empty => true)
      document << IqRdf::testemann.Foaf::knows("", :suppress_if_empty => true)
      document << IqRdf::testemann.Foaf::knows([], :suppress_if_empty => true)

      assert_equal("", document.to_ntriples.strip)
    end

  end
