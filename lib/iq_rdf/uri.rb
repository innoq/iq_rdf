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
  class Uri < Node

    attr_reader :namespace, :uri_postfix
    attr_reader :rdf_type

    def initialize(namespace, uri_postfix, rdf_type = nil, lang = nil)
      raise "rdf_type has to be an IqRdf::Uri" unless rdf_type.nil? || rdf_type.is_a?(IqRdf::Uri)
      @namespace = namespace
      @uri_postfix = uri_postfix
      @rdf_type = rdf_type
      super(lang)
    end

    def full_uri(parent_lang = nil)
      # URI::join etc won't work since uri_postfix has not to be a valid URI itself.
      "#{self.namespace.uri_prefix.to_s}#{self.uri_postfix.to_s}"
    end

    def to_s(options = {})
      if namespace.token # There is a dummy_empty_namespace without token => postfix is a full uri!
        "#{namespace.turtle_token}:#{self.uri_postfix.to_s}"
      else
        "<#{self.uri_postfix.to_s}>"
      end
    end

    def is_subject?
      if (nodes.size > 0) # walk through the nodes: a blank node is an object (but has nodes)
        nodes.each do |node|
          return true unless node.is_a?(BlankNode)
        end
      end
      return !rdf_type.nil?
    end

    def build_xml(xml, &block)
      if (is_subject?)
        attrs = {"rdf:about" => self.full_uri}
        attrs["xml:lang"] = self.lang if self.lang
        xml.rdf(:Description, attrs) do
          if self.rdf_type
            xml.rdf(:type, "rdf:resource" => self.rdf_type.full_uri)
          end
          self.nodes.each do |predicate|
            predicate.build_xml(xml)
          end
        end
      elsif block
        block.call("rdf:resource" => self.full_uri)
      end
    end

    # Method to add a blank node for the given predicate to the current subject
    # In contrast to the "method_missing" implementation, this method allows one
    # to choose a different namespace for the predicate.
    #
    # Usage:
    # document << IqRdf::Eg.build_uri('test', IqRdf::Eg.build_uri('testType')) do |uri|
    #   uri.add_blank_node(IqRdf::Eg, :component) do |blank_node|
    #     blank_node.build_predicate_with_ns(IqRdf::Eg, :order, 1)
    #   end
    # end
    #
    # Resulting in the following turtle syntax:
    # eg:test a eg:testType
    #         eg:component [
    #             eg:order 1
    #         ]
    def add_blank_node(namespace, postfix, &block)
      predicate = IqRdf::Predicate.new(namespace, postfix, self)
      blank_node = IqRdf::BlankNode.new

      block.call(blank_node)

      predicate << blank_node
      self << predicate
    end

  end
end
