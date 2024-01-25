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
  class BlankNode < Node

    attr_reader :node_id

    def initialize(node_id = nil)
      super
      @node_id = node_id
    end

    def to_turtle(parent_lang = nil)

    end

    def to_s(options = {})
      base_indent = options[:indent] || ""
      predicate_indent =  base_indent + "".ljust(4)

      predicates = nodes.map { |p| format_predicate(p, indent: predicate_indent, lang: options[:lang]) }
           .join(";\n")

      "[\n#{predicates}\n#{base_indent} ]"
    end

    def build_predicate(*args, &block)
      IqRdf::PredicateNamespace.new(self, IqRdf::Default).build_predicate(*args, &block)
    end

    def build_predicate_with_ns(namespace, *args, &block)
      IqRdf::PredicateNamespace.new(self, namespace).build_predicate(*args, &block)
    end

    def build_xml(xml, &block)
      block.call({}, lambda {
          attrs = {}
          attrs["xml:lang"] = self.lang if self.lang
          xml.rdf(:Description, attrs) do
            self.nodes.each do |predicate|
              predicate.build_xml(xml)
            end
          end
        })
    end

    private

    def format_predicate(predicate, options = {})
      subjects = predicate.nodes
                          .map { |object| object.to_s(indent: options[:indent], lang: predicate.lang || options[:lang]) }
                          .join(", ")

      "#{options[:indent]} #{predicate} #{subjects}"
    end

  end
end
