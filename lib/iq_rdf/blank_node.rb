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

    def to_s(parent_lang = nil)
      "[\n#{(nodes.map{|pred| "#{pred} #{pred.nodes.map{|o| o.to_s(pred.lang || parent_lang)}.join(", ")}"}.join(";\n")).gsub(/^/, "    ")}\n]"
    end

    def build_predicate(*args, &block)
      IqRdf::PredicateNamespace.new(self, IqRdf::Default).build_predicate(*args, &block)
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

  end
end
