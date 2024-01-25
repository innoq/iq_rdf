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
  class Collection

    attr_reader :elements

    def initialize(collection)
      @elements = []
      collection.each do |element|
        element = Literal.new(element) unless element.is_a?(IqRdf::Uri) || element.is_a?(IqRdf::Literal)
        @elements << element
      end
    end

    def to_s(options = {})
      "(#{@elements.map{|e| e.to_s(options)}.join(" ")})"
    end

    def build_xml(xml, elements = nil, &block)
      elements ||= @elements.dup
      block.call({},
        lambda {
          xml.rdf :List do
            elements.shift.build_xml(xml) do |*args|
              xml.rdf(:first, *args)
            end
            if elements.size > 0
              build_xml(xml, elements) do |opts, block|
                xml.rdf :rest do
                  block.call
                end
              end
            else
              xml.rdf :rest, "rdf:resource" => Rdf.nil.full_uri
            end
          end
        }
      )
    end

  end
end
