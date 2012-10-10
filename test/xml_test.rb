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

class XmlTest < Test::Unit::TestCase

  def test_basic_xml_output
    document = IqRdf::Document.new('http://www.test.de/', :lang => :de)
    document.namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

    document << IqRdf::testemann do |t|
      t.Foaf::knows(IqRdf::testefrau)
      t.Foaf.nick("Testy")
      t.Foaf.lastname("Testemann", :lang => :none)
    end

    assert_match(<<rdf, document.to_xml)
  <rdf:Description rdf:about="http://www.test.de/testemann">
    <foaf:knows rdf:resource="http://www.test.de/testefrau"/>
    <foaf:nick>Testy</foaf:nick>
    <foaf:lastname xml:lang="">Testemann</foaf:lastname>
  </rdf:Description>
rdf
  end

  def test_full_uri_subject_xml_output
    document = IqRdf::Document.new('http://www.test.de/')

    assert_raise RuntimeError do
      IqRdf::build_full_uri_subject("bla")
    end

    document << IqRdf::build_full_uri_subject(URI.parse('http://www.xyz.de/#test'), IqRdf::build_uri('SomeType')) do |t|
      t.sometest("testvalue")
    end

    assert_match(<<rdf, document.to_xml)
  <rdf:Description rdf:about="http://www.xyz.de/#test">
    <rdf:type rdf:resource="http://www.test.de/SomeType"/>
    <sometest>testvalue</sometest>
  </rdf:Description>
rdf
    end

    def test_complex_features
      document = IqRdf::Document.new('http://www.umweltprobenbank.de/', :lang => :de)

      document.namespaces :skos => 'http://www.w3.org/2008/05/skos#', :foaf => 'http://xmlns.com/foaf/0.1/', :upb => 'http://www.upb.de/'

      document << IqRdf::testemann.myCustomNote("This is an example", :lang => :en) # :testemann :myCustomNote "This is an example"@en.

      document << IqRdf::testemann(IqRdf::Foaf::build_uri("Person")).Foaf::name("Heinz Peter Testemann", :lang => :none) # :testemann a foaf:Person; foaf:name "Heinz Peter Testemann" .
      document << IqRdf::testemann.Foaf::knows(IqRdf::testefrau) # :testemann foaf:knows :testefrau .
      document << IqRdf::testemann.Foaf::nick("Crash test dummy") # :testemann foaf:nick "Crash test dummy"@de .

      document << IqRdf::testemann.testIt([IqRdf::hello, "bla"]) # :testIt (:hallo :goodbye "bla"@de), "blubb"@de;  # XML: rdf:list

      ["u1023", "xkfkrl"].each do |id|
        document << IqRdf::Upb::build_uri(id, IqRdf::Skos::build_uri(:Concept)) do |doc| # upb:#{id} a skos:Concept;
          doc.Skos::prefLabel("Test", :lang => :en) # skos:prefLabel "Test"@en;
          doc.Skos::related(IqRdf::Rdf.anotherThing) # skos:related test:another_thing;

          doc.test1("bla") # :test1 "bla"@de;
          doc.testIt(:hello, :goodbye, "bla") # :testIt :hallo, :goodbye, "bla"@de;
          doc.anotherTest(URI.parse("http://www.test.de/foo")) # :anotherTest <http://www.test.de/foo>;

        end # .
      end
      document << IqRdf::Skos::testnode.test32 do |blank_node| # Blank nodes # skos:testnode :test32 [
        blank_node.title("dies ist ein test") # :title "dies ist ein test"@de;
        blank_node.sub do |subnode| # sub [
          subnode.title("blubb") # title "blubb"
        end # ]
      end # ]

      assert_match(<<rdf, document.to_xml)
  <rdf:Description rdf:about="http://www.umweltprobenbank.de/testemann">
    <myCustomNote xml:lang="en">This is an example</myCustomNote>
  </rdf:Description>
  <rdf:Description rdf:about="http://www.umweltprobenbank.de/testemann">
    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person"/>
    <foaf:name xml:lang="">Heinz Peter Testemann</foaf:name>
  </rdf:Description>
  <rdf:Description rdf:about="http://www.umweltprobenbank.de/testemann">
    <foaf:knows rdf:resource="http://www.umweltprobenbank.de/testefrau"/>
  </rdf:Description>
  <rdf:Description rdf:about="http://www.umweltprobenbank.de/testemann">
    <foaf:nick>Crash test dummy</foaf:nick>
  </rdf:Description>
  <rdf:Description rdf:about="http://www.umweltprobenbank.de/testemann">
    <testIt>
      <rdf:List>
        <rdf:first rdf:resource="http://www.umweltprobenbank.de/hello"/>
        <rdf:rest>
          <rdf:List>
            <rdf:first>bla</rdf:first>
            <rdf:rest rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"/>
          </rdf:List>
        </rdf:rest>
      </rdf:List>
    </testIt>
  </rdf:Description>
  <rdf:Description rdf:about="http://www.upb.de/u1023">
    <rdf:type rdf:resource="http://www.w3.org/2008/05/skos#Concept"/>
    <skos:prefLabel xml:lang="en">Test</skos:prefLabel>
    <skos:related rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#anotherThing"/>
    <test1>bla</test1>
    <testIt rdf:resource="http://www.umweltprobenbank.de/hello"/>
    <testIt rdf:resource="http://www.umweltprobenbank.de/goodbye"/>
    <testIt>bla</testIt>
    <anotherTest rdf:resource="http://www.test.de/foo"/>
  </rdf:Description>
  <rdf:Description rdf:about="http://www.upb.de/xkfkrl">
    <rdf:type rdf:resource="http://www.w3.org/2008/05/skos#Concept"/>
    <skos:prefLabel xml:lang="en">Test</skos:prefLabel>
    <skos:related rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#anotherThing"/>
    <test1>bla</test1>
    <testIt rdf:resource="http://www.umweltprobenbank.de/hello"/>
    <testIt rdf:resource="http://www.umweltprobenbank.de/goodbye"/>
    <testIt>bla</testIt>
    <anotherTest rdf:resource="http://www.test.de/foo"/>
  </rdf:Description>
  <rdf:Description rdf:about="http://www.w3.org/2008/05/skos#testnode">
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

=begin
skos:testnode :test32 [
    :title "dies ist ein test"@de;
    :sub [
        :title "blubb"@de
    ]
].
=end
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
        t.complex(IqRdf::Literal.new("A very complex type", :none, URI.parse("http://this.com/is#complex")))
        t.complex2(IqRdf::Literal.new("Shorter form", :none, IqRdf::myDatatype))
        t.quotes("\"I'm \\quoted\"")
        t.line_breaks("I'm written\nover two lines")
        t.some_literal(IqRdf::Literal.new("text", :de))
      end

      assert_match(<<rdf, document.to_xml)
  <rdf:Description rdf:about="http://www.test.de/testemann">
    <foaf:knows rdf:resource="http://www.test.de/testefrau"/>
    <foaf:nick>Testy</foaf:nick>
    <foaf:lastname xml:lang="">Testemann</foaf:lastname>
    <age rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">32</age>
    <married rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">false</married>
    <weight rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">65.8</weight>
    <complex rdf:datatype="http://this.com/is#complex" xml:lang="none">A very complex type</complex>
    <complex2 rdf:datatype="http://www.test.de/myDatatype" xml:lang="none">Shorter form</complex2>
    <quotes>"I'm \\quoted"</quotes>
    <line_breaks>I'm written
over two lines</line_breaks>
    <some_literal xml:lang="de">text</some_literal>
  </rdf:Description>
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
    assert_match(<<rdf, document.to_xml)
  <rdf:Description rdf:about=\"http://www.test.de/testnode\">
    <test32>
      <rdf:Description>
        <title>dies ist ein test</title>
        <test>Another test</test>
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

  end
