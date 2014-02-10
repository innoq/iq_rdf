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
  class Predicate < Uri

    attr_reader :subject

    def initialize(namespace, uri_postfix, subject, lang = nil)
      super(namespace, uri_postfix, nil, lang)
      @subject = subject
    end

    def build_xml(xml)
      nodes.each do |node|
        node.build_xml(xml) do |*args|
          block = args.pop if args.last.is_a?(Proc)
          params = if namespace.token.nil? # Full uri
            nameStartChar = "[A-Z]|_|[a-z]|[\u{00C0}-\u{00D6}]|[\u{00D8}-\u{00F6}]|[\u{00F8}-\u{02FF}]|[\u{0370}-\u{037D}]|[\u{037F}-\u{1FFF}]|[\u{200C}-\u{200D}]|[\u{2070}-\u{218F}]|[\u{2C00}-\u{2FEF}]|[\u{3001}-\u{D7FF}]|[\u{F900}-\u{FDCF}]|[\u{FDF0}-\u{FFFD}]|[\u{10000}-\u{EFFFF}]"
            name = Regexp.new("^(.*?)((#{nameStartChar})(#{nameStartChar}|-|[0-9]|\u{00B7}|[\u{0300}-\u{036F}]|[\u{203F}-\u{2040}])*)$")
            unless matches = name.match(self.uri_postfix.to_s)
              raise "Coudln't extract namespace and postfix from URI '#{self.uri_postfix}'"
            end
            ["ns0", matches[2].to_sym, {"xmlns:ns0" => matches[1]}]
          else
            namespace.token == :default ? [self.uri_postfix.to_s] : [namespace.token.to_s, self.uri_postfix.to_sym]
          end
          params += args
          params << {"xml:lang" => xml_lang} if xml_lang
          if block
            xml.tag!(*params) do
              block.call
            end
          else
            xml.tag!(*params)
          end
        end
      end
    end

  end
end
