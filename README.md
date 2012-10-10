# IqRdf - RDF Renderering for Ruby and Rails [![build status](https://secure.travis-ci.org/innoq/iq_rdf.png)](http://travis-ci.org/innoq/iq_rdf)
IqRdf is a RDF renderer for Ruby and Rails. You can use it in any Ruby
environment to render Trurtle-, N-Triple- (not implemented jet) or XML-RDF.

IqRdf underlays a [Builder](http://builder.rubyforge.org/)-like approach to specify
the RDF-Data by using a internal Ruby DSL. The basic Idea for specifing a triple
(subject, predicate, object) is that the predicate is a method call on the
subject with the object as parameters:

```ruby
IqRdf::some_subject.some_predicate(IqRdf::some_object)
```

The IqRdf namespaces are needed not to mess up the rest of your project due to
the heavy use of method_missing in the IqRdf-Library. See the IqRdf::use method
for Ruby 1.9 to omit the `IqRdf::` prefix.

## Ruby example
You can use IqRdf in pure Ruby to produce Strings in a certain RDF Syntax like
Turtle or XML:

```ruby
require 'IqRdf'
document = IqRdf::Document.new('http://www.test.de/')

document.namespaces :skos => 'http://www.w3.org/2008/05/skos#',
  :foaf => 'http://xmlns.com/foaf/0.1/' # A :rdf namespace is added automatically

document << IqRdf::john_doe.myCustomNote("This is an example", :lang => :en)
# Turtle: :john_doe :myCustomNote "This is an example"@en.

document << IqRdf::john_doe(IqRdf::Foaf::build_uri("Person")).Foaf::name("John Doe")
# Turtle: :john_doe a foaf:Person; foaf:name "John Doe".

document << IqRdf::john_doe.Foaf::knows(IqRdf::jane_doe)
# Turtle: :john_doe foaf:knows :jane_doe.

document.to_turtle
# => "@prefix : <http://www.test.de/>. ..."
```

## Rails example
Include IqRdf to your Ruby on Rails project by adding the following line to your
Gemfile (or with Rails 2.x in your config/environment.rb):

```ruby
gem "iq_rdf"
```

Add the mime types you want to support to your config/initializers/mime_types.rb
file:

```ruby
Mime::Type.register "application/rdf+xml", :rdf
Mime::Type.register "text/turtle", :ttl
Mime::Type.register "application/n-triples", :nt
```

Now you can define views in you application. Use the extension *.iqrdf*
for the view files. You can use the extensions *.ttl* or
*.rdf* in the URL of your request, to force the output to be
in Turtle or XML/RDF.

### Views
In your views IqRdf gives you a *document* object you can add your triples
to. But first you will have to define your namespaces and the global language if
you want to label all String literals in a certain language (as long as there is
no other language or `:none` given).

```ruby
document.namespaces :default => 'http://data.example.com/', :foaf => 'http://xmlns.com/foaf/0.1/'
document.lang = :en

document << IqRdf::test_subject.test_predicate("test")
# Turtle: :test_subject :test_predicate "test"@en.

document << IqRdf::test_subject.test_predicate("test", :lang => :de)
# Turtle: :test_subject :test_predicate "test"@de.

document << IqRdf::test_subject.test_predicate("test", :lang => :none)
# Turtle: :test_subject :test_predicate "test".

# ...
```

Use the namespace token `:default` to mark the default namespace. This has the
same effect as specifing the default namespace in `IqRdf::Document.new`.

## Complex RDF definitions
TODO

Copyright (c) 2011 innoQ Deutschland GmbH, released under the Apache License 2.0
