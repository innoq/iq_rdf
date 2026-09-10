# Changelog

## [0.3.0] - 2026-09-10

* omit `rdf:type rdf:List` from RDF collections. The list structure is fully
  defined by `rdf:first`/`rdf:rest`/`rdf:nil`, and Turtle's `( ... )` form
  cannot express the type at all, so emitting it made the same data count
  differently per format. **Documents containing collections now serialize to
  fewer triples**, and N-Triples, Turtle and RDF/XML agree on the count. In
  RDF/XML, list nodes are now `rdf:Description` rather than `rdf:List`.

## [0.2.3] - 2026-09-10

* fix Turtle serialization of literals containing a carriage return. A long
  string (`"""..."""`) was only used for newlines, so a lone carriage return
  ended up raw inside a short string - invalid Turtle, which made parsers drop
  the statement without warning. Quotes are now escaped inside long strings as
  well, so a value ending in a quote or containing three of them no longer
  breaks the output.
* serialize Turtle in linear rather than quadratic time. Building the output
  with `+=` copied the whole string on every append, which made large documents
  effectively impossible to serialize.
* serialize N-Triples faster by not counting a Hash with `Enumerable#count`,
  which walks and allocates per entry. On a document with many blank nodes this
  dominated the runtime.
* add `rdf-turtle` as a development dependency, so that tests can parse
  generated output back instead of only comparing it to an expected string.

## [0.2.2] - 2026-07-31

* fix N-Triples serialization of literals containing newlines, tabs or
  carriage returns
* drop support for end-of-life rubies

## [0.2.1]

* fix a frozen string literal warning
