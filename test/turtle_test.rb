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

class TurtleTest < Test::Unit::TestCase

  def test_basic_turtle_output
    document = IqRdf::Document.new('http://www.test.de/', :lang => :de)
    document.namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

    document << IqRdf::testemann do |t|
      t.Foaf::knows(IqRdf::testefrau)
      t.Foaf.nick("Testy")
      t.Foaf.lastname("Testemann", :lang => :none)
    end

    assert_equal(<<rdf, document.to_turtle)
@prefix : <http://www.test.de/>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix foaf: <http://xmlns.com/foaf/0.1/>.

:testemann foaf:knows :testefrau;
           foaf:nick "Testy"@de;
           foaf:lastname "Testemann".
rdf
  end

  def test_full_uri_subject_turtle_output
    document = IqRdf::Document.new('http://www.test.de/')

    assert_raise RuntimeError do
      IqRdf::build_full_uri_subject("bla")
    end

    document << IqRdf::build_full_uri_subject(URI.parse('http://www.xyz.de/#test'), IqRdf::build_uri('SomeType')) do |t|
      t.sometest("testvalue")
    end

    assert_equal(<<rdf, document.to_turtle)
@prefix : <http://www.test.de/>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.

<http://www.xyz.de/#test> a :SomeType;
                          :sometest "testvalue".
rdf
  end

  def test_complex_features
    document = IqRdf::Document.new('http://www.umweltprobenbank.de/', :lang => :de)

    document.namespaces :skos => 'http://www.w3.org/2008/05/skos#', :foaf => 'http://xmlns.com/foaf/0.1/', :upb => 'http://www.upb.de/'

    document << IqRdf::testemann.myCustomNote("This is an example", :lang => :en) # :testemann :myCustomNote "This is an example"@en.

    document << IqRdf::testemann(IqRdf::Foaf::build_uri("Person")).Foaf::name("Heinz Peter Testemann", :lang => :none) # :testemann a foaf:Person; foaf:name "Heinz Peter Testemann" .
    document << IqRdf::testemann.Foaf::knows(IqRdf::testefrau) # :testemann foaf:knows :testefrau .
    document << IqRdf::testemann.Foaf::nick("Crash test dummy") # :testemann foaf:nick "Crash test dummy"@de .

    ["u1023", "xkfkrl"].each do |id|
      document << IqRdf::Upb::build_uri(id, IqRdf::Skos::build_uri(:Concept)) do |doc| # upb:#{id} a skos:Concept;
        doc.Skos::prefLabel("Test", :lang => :en) # skos:prefLabel "Test"@en;
        doc.Skos::related(IqRdf::Rdf.anotherThing) # skos:related test:another_thing;

        doc.test1("bla") # :test1 "bla"@de;
        doc.testIt(:hello, :goodbye, "bla") # :testIt :hallo, :goodbye, "bla"@de;
        doc.testIt([IqRdf::hello, IqRdf::goodbye, "bla"], "blubb") # :testIt (:hallo :goodbye "bla"@de), "blubb"@de;  # XML: rdf:list
        doc.anotherTest(URI.parse("http://www.test.de/foo")) # :anotherTest <http://www.test.de/foo>;

      end # .
    end

    document << IqRdf::Skos::testnode.test32 do |blank_node| # Blank nodes # skos:testnode :test32 [
      blank_node.title("dies ist ein test") # :title "dies ist ein test"@de;
      blank_node.sub do |subnode| # sub [
        subnode.title("blubb") # title "blubb"
      end # ]
    end # ]

    assert_equal(<<rdf, document.to_turtle)
@prefix : <http://www.umweltprobenbank.de/>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix skos: <http://www.w3.org/2008/05/skos#>.
@prefix foaf: <http://xmlns.com/foaf/0.1/>.
@prefix upb: <http://www.upb.de/>.

:testemann :myCustomNote "This is an example"@en.
:testemann a foaf:Person;
           foaf:name "Heinz Peter Testemann".
:testemann foaf:knows :testefrau.
:testemann foaf:nick "Crash test dummy"@de.
upb:u1023 a skos:Concept;
          skos:prefLabel "Test"@en;
          skos:related rdf:anotherThing;
          :test1 "bla"@de;
          :testIt :hello, :goodbye, "bla"@de;
          :testIt (:hello :goodbye "bla"@de), "blubb"@de;
          :anotherTest <http://www.test.de/foo>.
upb:xkfkrl a skos:Concept;
           skos:prefLabel "Test"@en;
           skos:related rdf:anotherThing;
           :test1 "bla"@de;
           :testIt :hello, :goodbye, "bla"@de;
           :testIt (:hello :goodbye "bla"@de), "blubb"@de;
           :anotherTest <http://www.test.de/foo>.
skos:testnode :test32 [
    :title "dies ist ein test"@de;
    :sub [
        :title "blubb"@de
    ]
].
rdf
  end

  def test_literals
    document = IqRdf::Document.new('http://www.test.de/', :lang => :de)
    document.namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

    document << IqRdf::testemann do |t|
      t.Foaf::knows(:testefrau)
      t.Foaf.nick("Testy")
      t.Foaf.lastname("Testemann", :lang => :none)
      t.age(32)
      t.married(false)
      t.weight(65.8)
      t.quotes("\"I'm \\quoted\"")
      t.line_breaks("I'm written\nover two lines")
      t.some_literal(IqRdf::Literal.new("text", :de))
      t.messy(IqRdf::PlainTurtleLiteral.new('"this_already_is_in_turtle_format"@en'))
    end

    assert_equal(<<rdf, document.to_turtle)
@prefix : <http://www.test.de/>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix foaf: <http://xmlns.com/foaf/0.1/>.

:testemann foaf:knows :testefrau;
           foaf:nick "Testy"@de;
           foaf:lastname "Testemann";
           :age 32;
           :married false;
           :weight 65.8;
           :quotes "\\"I'm \\\\quoted\\""@de;
           :line_breaks """I'm written
over two lines"""@de;
           :some_literal "text"@de;
           :messy "this_already_is_in_turtle_format"@en.
rdf
  end

  def test_supress_if_empty_otpion
    document = IqRdf::Document.new('http://www.test.de/')
    document.namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

    document << IqRdf::testemann.Foaf::knows(:suppress_if_empty => true)
    document << IqRdf::testemann.Foaf::knows(nil, :suppress_if_empty => true)
    document << IqRdf::testemann.Foaf::knows("", :suppress_if_empty => true)
    document << IqRdf::testemann.Foaf::knows([], :suppress_if_empty => true)
    assert_equal(<<rdf, document.to_turtle)
@prefix : <http://www.test.de/>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix foaf: <http://xmlns.com/foaf/0.1/>.

rdf
  end

  def test_full_uri_predicates
    document = IqRdf::Document.new('http://www.test.de/')

    document << IqRdf::testemann.build_full_uri_predicate(URI.parse("http://www.test.org/hoho"), 42)

    assert_equal(<<rdf, document.to_turtle)
@prefix : <http://www.test.de/>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.

:testemann <http://www.test.org/hoho> 42.
rdf
  end

  def test_blank_nodes
    document = IqRdf::Document.new('http://www.test.de/')

    document << IqRdf::testnode.test32 do |blank_node| # Blank nodes # :testnode :test32 [
      blank_node.title("dies ist ein test") # :title "dies ist ein test";
      blank_node.build_predicate(:test, "Another test") # :test "Another test";
      blank_node.sub do |subnode| # sub [
        subnode.title("blubb") # title "blubb"
      end # ]
    end # ]
    assert_equal(<<rdf, document.to_turtle)
@prefix : <http://www.test.de/>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.

:testnode :test32 [
    :title "dies ist ein test";
    :test "Another test";
    :sub [
        :title "blubb"
    ]
].
rdf
  end

end
