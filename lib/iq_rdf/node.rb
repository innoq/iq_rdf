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

module IqRdf
  class Node
    attr_reader :nodes
    attr_reader :lang

    def initialize(lang = nil)
      @nodes = []
      @lang = lang
    end

    # You can add Nodes (Uris, Blank Nodes, Predicates), Literals and Collections
    # So a Node has the following structure:
    #  <node> <uri> or <node> <literal> (tuple)
    #  <node> <predicate> == <node> (<predicate_node> <predicate.nodes>) (triples)
    def <<(node)
      raise ArgumentError, "#{node.inspect} is no IqRdf::Node or a IqRdf::Literal or a IqRdf::Collection" unless node.is_a?(IqRdf::Node) || node.is_a?(IqRdf::Literal) || node.is_a?(IqRdf::Collection)
      @nodes << node
    end

    def method_missing(method_name, *args, &block)
      if (namespace_class = Namespace.find_namespace_class(method_name))
        return IqRdf::PredicateNamespace.new(self, namespace_class) # some_node.>namespace<...
      else
        return IqRdf::PredicateNamespace.new(self, IqRdf::Default).build_predicate(method_name, *args, &block) # some_node.>predicate<()
      end
    end

    def is_subject?()
      false
    end

    def build_full_uri_predicate(uri, *args, &block)
      raise ArgumentError, "uri musst be an ::URI" unless uri.is_a?(::URI)

      IqRdf::PredicateNamespace.new(self, Namespace.dummy_empty_namespace).build_predicate(uri, *args, &block)
    end

    def xml_lang
      @lang && (@lang == :none ? "" : @lang)
    end

  end
end
