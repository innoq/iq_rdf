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

require 'iq_rdf/node'
require 'iq_rdf/uri'
require 'iq_rdf/blank_node'
require 'iq_rdf/predicate'

require 'iq_rdf/literal'
require 'iq_rdf/literal/boolean'
require 'iq_rdf/literal/string'
require 'iq_rdf/literal/uri'
require 'iq_rdf/literal/numeric'
require 'iq_rdf/namespace'
require 'iq_rdf/collection'
require 'iq_rdf/predicate_namespace'
require 'iq_rdf/document'

require 'builder'

require 'uri'

if defined?(ActionView::Template)
  require 'iq_rdf/rails/iq_rdf'
end

# The main module of IqRdf.
module IqRdf

  # This is needed for a system check in the "use" method.
  module TestModule #:nodoc:
  end
  TestModule::module_eval {TEST_CONST = 1} #:nodoc: Where will TEST_CONST be defined? TestModule::TEST_CONST (Ruby 1.9) or IqRdf::TEST_CONST (Ruby 1.8 and JRuby)

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

  def self.build_full_uri_subject(uri, type = nil, &block)
    raise "Parameter uri has to be an URI" unless uri.is_a?(URI)
    Namespace.dummy_empty_namespace.build_uri(uri, type, &block)
  end

  def self.find_or_create_namespace_class(klass_name)
    if RUBY_VERSION < "1.9"
      self.const_defined?(klass_name) ? self.const_get(klass_name) : self.const_set(klass_name, Class.new(IqRdf::Namespace))
    else
      self.const_defined?(klass_name, false) ? self.const_get(klass_name, false) : self.const_set(klass_name, Class.new(IqRdf::Namespace))
    end
  end

end
