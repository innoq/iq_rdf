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
  class Document

    def initialize(default_namespace_uri_prefix = nil, *args)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      raise ArgumentError, "If given, parameter :lang has to be a Symbol" unless options[:lang].nil? || options[:lang].is_a?(Symbol)

      self.namespaces(:default => default_namespace_uri_prefix) if default_namespace_uri_prefix
      self.namespaces(:rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#")

      @document_language = options[:lang]

      @nodes = []
      @config = {}
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

    def config(config = {})
      @config = config
    end

    def <<(node)
      return if node.nil?
      raise ArgumentError, "Node must be an IqRdf::Uri and a Subject!" unless node.is_a?(IqRdf::Uri) and node.is_subject?
      @nodes << node
    end

    def to_ntriples
      rdf_type = IqRdf::Rdf::build_uri("type")
      triples = []
      blank_nodes = {}

      # pre-declarations -- XXX: smelly!
      render_triple = nil
      process_subject = nil

      render_blank_node = lambda do |res|
        node_id = blank_nodes[res]
        unless node_id
          node_id = blank_nodes.count + 1
          blank_nodes[res] = node_id
        end
        return "_:b#{node_id}"
      end

      process_collection = lambda do |res|
        list = render_blank_node.call(res)
        # inject list components
        list = IqRdf::BlankNode.new
        sublist = list
        total = res.elements.length
        res.elements.each_with_index do |current_element, i|
          sublist::rdf.build_predicate("type", IqRdf::Rdf::build_uri("List")) # _:b* a rdf:List
          sublist::rdf.first(current_element) # _:b* rdf:first <...>
          last = i + 1 == total
          if last
            sublist::rdf.rest(IqRdf::Rdf::build_uri("nil"))
          else
            new_sublist = IqRdf::BlankNode.new
            sublist::rdf.rest(new_sublist) # _:b* rdf:rest _:b*
          end
          process_subject.call(sublist)
          sublist = new_sublist
        end
        return render_blank_node.call(list)
      end

      render_resource = lambda do |res, lang| # XXX: does not belong here
        if res.is_a?(IqRdf::Literal)
          return res.to_ntriples(lang)
        elsif res.is_a?(IqRdf::BlankNode)
          return render_blank_node.call(res)
        elsif res.is_a?(IqRdf::Collection)
          return process_collection.call(res)
        else
          return "<#{res.full_uri}>"
        end
      end

      render_triple = lambda do |(sbj, prd, obj), lang| # XXX: language handling is weird!? -- XXX: does not belong here
        triple = [sbj, prd, obj].map { |res| render_resource.call(res, lang) }
        return "#{triple.join(" ")} ."
      end

      process_subject = lambda do |sbj, &block| # XXX: does not belong here
        if (sbj.rdf_type rescue false) # XXX: `rescue` a hack for blank nodes
          lang = sbj.lang || @document_language # XXX: cargo-culted
          triples << render_triple.call([sbj, rdf_type, sbj.rdf_type], lang)
        end

        sbj.nodes.each do |prd|
          lang = prd.lang || sbj.lang || @document_language # XXX: cargo-culted
          prd.nodes.each do |obj|
            triple = [sbj, prd, obj]
            triples << render_triple.call(triple, lang)
            block.call(triple) if block
          end
        end
      end

      process_blank_node = lambda do |(sbj, prd, obj), current_res|
        [sbj, obj].
            select { |res| res.is_a?(IqRdf::BlankNode) && res != current_res }.
            each do |res|
          process_subject.call(res) do |(sbj, prd, obj)|
            process_blank_node.call([sbj, prd, obj], res) # NB: recursion!
          end
        end
      end

      @nodes.each do |sbj|
        process_subject.call(sbj) do |(sbj, prd, obj)|
          process_blank_node.call([sbj, prd, obj], sbj) # XXX: special casing
        end
      end

      return triples.join("\n") + "\n"
    end

    def to_turtle
      s = ""
      @namespaces.values.sort{ |n1, n2| n1.turtle_token <=> n2.turtle_token }.each do |namespace|
        s += "@prefix #{namespace.turtle_token}: <#{namespace.uri_prefix}>.\n"
      end
      s += "\n"
      @nodes.each do |subject|
        pref = subject.to_s(@document_language)
        indent = "".ljust(pref.length)

        # Render subject, if it is defined as a RDF-type.
        if subject.rdf_type
          s += "#{pref} a #{subject.rdf_type}"
          pref = ";\n" + indent
        end

        # Render all predicates and their associated objects
        subject.nodes.each do |predicate|
          objects = predicate.nodes.map { |object| object.to_s(indent: indent, lang: predicate.lang || subject.lang || @document_language) }
                             .join(", ")

          s += "#{pref} #{predicate.to_s} #{objects}"

          pref = ";\n" + indent
        end
        s += ".\n"
        if @config[:empty_line_between_triples]
          s += "\n"
        end
      end
      s
    end

    def to_xml
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      opts = {}
      @namespaces.values.each do |namespace|
        opts[namespace.token == :default ? "xmlns" : "xmlns:#{namespace.token.to_s}"] = namespace.uri_prefix
      end
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
