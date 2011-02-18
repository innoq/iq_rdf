#   Copyright 2011 Till Schulte-Coerne (innoQ Deutschland GmbH)
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
  class Document

    def initialize(default_namespace_uri_prefix = nil, *args)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      raise ArgumentError, "If given, parameter :lang has to be a Symbol" unless options[:lang].nil? || options[:lang].is_a?(Symbol)

      self.namespaces(:default => default_namespace_uri_prefix) if default_namespace_uri_prefix
      self.namespaces(:rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#")

      @document_language = options[:lang]

      @nodes = []
    end

    def namespaces(namespaces)
      raise ArgumentError, "Parameter 'namespaces' has to be a hash" unless namespaces.is_a?(Hash)

      namespaces.each do |name, uri_prefix|
        uri_prefix = ::URI.parse(uri_prefix)
        raise ArgumentError, "Parameter 'namespaces' must be im the form {Symbol => URIString, ...}" unless name.is_a? Symbol

        register_namespace(name, uri_prefix)
      end
      self
    end

    def <<(node)
      return if node.nil?
      raise ArgumentError, "Node must be an IqRdf::Uri and a Subject!" unless node.is_a?(IqRdf::Uri) and node.is_subject?
      @nodes << node
    end

    def to_turtle
      s = ""
      @namespaces.values.each do |namespace|
        s << "@prefix #{namespace.turtle_token}: <#{namespace.uri_prefix}>.\n"
      end
      s << "\n"
      @nodes.each do |node|
        pref = "#{node.to_s(@document_language)}"
        if node.rdf_type
          s << "#{pref} a #{node.rdf_type}"
          pref = ";\n" + "".ljust(node.to_s(@document_language).length)
        end
        node.nodes.each do |predicate|
          s << "#{pref} #{predicate.to_s} #{predicate.nodes.map{|o| o.to_s(predicate.lang || node.lang || @document_language)}.join(", ")}"
          pref = ";\n" + "".ljust(node.to_s(@document_language).length)
        end
        s << ".\n"
      end
      s
    end

    def to_xml
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      opts = {}
      @namespaces.values.each{ |namespace|
        opts[namespace.token == :default ? "xmlns" : "xmlns:#{namespace.token.to_s}"] = namespace.uri_prefix
      }
      opts["xml:lang"] = @document_language if @document_language

      xml.rdf(:RDF, opts) do
        @nodes.each do |node|
          node.build_xml(xml)
        end
      end
      xml.target!
    end

    private

    def register_namespace(name, uri_prefix)
      (@namespaces ||= {})[name] = IqRdf::Namespace.create(name, uri_prefix)
    end

  end
end