require 'iq_rdf/node'
require 'iq_rdf/uri'
require 'iq_rdf/blank_node'
require 'iq_rdf/predicate'

require 'iq_rdf/literal'
require 'iq_rdf/plain_turtle_literal'
require 'iq_rdf/namespace'
require 'iq_rdf/collection'
require 'iq_rdf/predicate_namespace'
require 'iq_rdf/document'

require 'uri'

# The main module of IqRdf.
module IqRdf

  # This is needed for a system check in the "use" method.
  module TestModule #:nodoc:
  end
  TestModule::module_eval {TEST_CONST = 1} #:nodoc: Where will TEST_CONST be difined? TestModule::TEST_CONST (Ruby 1.9) or IqRdf::TEST_CONST (Ruby 1.8 and JRuby)

  # This evals the given block in the context of IqRdF.
  # You can use this to be able to omit the "IqRdf::" in your turtle statements.
  #
  # Example:
  #   IqRdf::use do
  #     mySubject Rdf::type Skos::Concept # => mySubject rdf:type skos:Concept
  #   end
  #
  # But: There is an inconsistency in Ruby 1.8 and JRuby <= 1.4 (even with --1.9):
  #   module M; end
  #   M.module_eval {C = 1; self::D = 1}
  #   p defined? M::C # => nil (should be "constant" (and is in C Ruby 1.9))
  #   p defined? M::D # => "constant"
  # This means, that _use_ will only work with Ruby 1.9. Feel free to change
  # this if you know another way then module_eval to achieve this.
  def self.use(&block)
    raise NotImplementedError, "This is not supported in your Ruby version." unless defined?(TestModule::TEST_CONST)
    self.module_eval(&block)
  end

  # A shortcut so be able to define Subjects and Objects without specifing a
  # namespace. When no namespace is given, Default will be used.
  #
  # Example:
  #   IqRdf::sub.pred(IqRdf::obj) # => :sub :pred :obj.
  def self.method_missing(method_name, *args, &block)
    IqRdf::Default.send(method_name, *args, &block)
  end

end