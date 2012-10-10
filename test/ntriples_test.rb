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

    assert_equal(<<-rdf.strip, document.to_ntriples)
<http://example.org/foo> <http://www.w3.org/2004/02/skos/core#related> <http://example.org/bar> .
    rdf

    document = IqRdf::Document.new('http://www.test.de/', :lang => :de)
    document.namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

    document << IqRdf::testemann do |t|
      t.Foaf::knows(IqRdf::testefrau)
      t.Foaf.nick("Testy")
      t.Foaf.lastname("Testemann", :lang => :none)
    end

    assert_equal(<<-rdf.strip, document.to_ntriples)
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/knows> <http://www.test.de/testefrau> .
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/nick> "Testy"@de .
<http://www.test.de/testemann> <http://xmlns.com/foaf/0.1/lastname> "Testemann" .
    rdf
  end

end
