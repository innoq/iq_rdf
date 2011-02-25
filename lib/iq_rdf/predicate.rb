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
      raise "XML Output won't work with full URIs as predicates yet" unless namespace.token # There is a dummy_empty_namespace without token => postfix is a full uri!
      nodes.each do |node|
        node.build_xml(xml) do |*args|
          block = args.pop if args.last.is_a?(Proc)
          params = namespace.token == :default ? [self.uri_postfix.to_s] : [namespace.token.to_s, self.uri_postfix.to_sym]
          params += args
          params << {"xml:lang" => xml_lang} if xml_lang
          if block
            xml.tag!(*params, &block)
          else
            xml.tag!(*params)
          end
        end
      end
    end

  end
end
