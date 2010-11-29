require 'test/test_helper'

class IqRdfTest < Test::Unit::TestCase

  def test_namespace_definitions
    assert_raise(URI::InvalidURIError) { IqRdf::Document.new(12345) }

    document = IqRdf::Document.new("http://default-namespace.com/")

    assert_raise(ArgumentError) { document.namespaces :nohash }
    assert_raise(ArgumentError) { document.namespaces "wrong" => "http://www.innoq.com/" }
    assert_raise(URI::InvalidURIError) { document.namespaces :correct => 12 }

    document.namespaces :innoq => "http://www.innoq.com/"
    document.namespaces :uba => "http://www.uba.de/"

    IqRdf::Innoq::uri_prefix

    assert_equal("http://default-namespace.com/", IqRdf::uri_prefix.to_s)
    assert_equal("http://www.innoq.com/", IqRdf::Innoq::uri_prefix.to_s)
    assert_equal("http://www.uba.de/", IqRdf::Uba::uri_prefix.to_s)

  end

  def test_uri_definitions
    IqRdf::Document.new("http://default-namespace.com/").namespaces :innoq => 'http://www.innoq.com/'

    IqRdf::Innoq::tillsc

    assert_equal("http://default-namespace.com/foo", IqRdf::foo.full_uri)
    assert_equal("http://www.innoq.com/tillsc", IqRdf::Innoq::tillsc.full_uri)
  end

  def test_disallow_nested_definitions
    IqRdf::Document.new('http://www.umweltprobenbank.de/').namespaces :foaf => 'http://xmlns.com/foaf/0.1/'

    assert_raise(ArgumentError) {IqRdf::testemann.Foaf::knows(IqRdf::testefrau.Foaf::knows(IqRdf::someone_else)) }
  end

end
