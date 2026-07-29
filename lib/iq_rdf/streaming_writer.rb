module IqRdf
  class StreamingWriter

    FORMATS = %w[ttl nt xml].freeze

    def initialize(io, format, default_namespace: nil, lang: nil, config: {})
      @io = io
      @format = format.to_s
      raise ArgumentError, "Unknown format '#{format}'. Must be one of: #{FORMATS.join(', ')}" unless FORMATS.include?(@format)
      @document_language = lang
      @config = config
      @namespaces = {}
      @header_written = false
      @blank_nodes = {}

      register_namespace(:rdf, URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
      namespaces(default: default_namespace) if default_namespace
    end

    def namespaces(namespaces)
      raise ArgumentError, "Parameter 'namespaces' has to be a hash" unless namespaces.is_a?(Hash)
      namespaces.each do |name, uri_prefix|
        uri_prefix = ::URI.parse(uri_prefix)
        raise ArgumentError, "Parameter 'namespaces' must be in the form {Symbol => URIString, ...}" unless name.is_a?(Symbol)
        register_namespace(name, uri_prefix)
      end
      self
    end

    def <<(node)
      return if node.nil?
      raise ArgumentError, "Node must be an IqRdf::Uri and a Subject!" unless node.is_a?(IqRdf::Uri) && node.is_subject?
      write_header unless @header_written
      serialize_node(node)
    end

    def close
      write_xml_footer if @format == 'xml' && @header_written
    end

    def self.open(io, format, **opts)
      writer = new(io, format, **opts)
      yield writer
    ensure
      writer&.close
    end

    private

    def register_namespace(name, uri_prefix)
      @namespaces[name] = IqRdf::Namespace.create(name, uri_prefix)
    end

    def write_header
      case @format
      when 'ttl' then write_turtle_header
      when 'xml' then write_xml_header
      end
      @header_written = true
    end

    def serialize_node(subject)
      case @format
      when 'ttl' then serialize_turtle(subject)
      when 'nt'  then serialize_ntriples(subject)
      when 'xml' then serialize_xml(subject)
      end
    end

    # --- Turtle ---

    def write_turtle_header
      @namespaces.values.sort_by(&:turtle_token).each do |namespace|
        @io.write("@prefix #{namespace.turtle_token}: <#{namespace.uri_prefix}>.\n")
      end
      @io.write("\n")
    end

    def serialize_turtle(subject)
      pref = subject.to_s
      indent = "".ljust(pref.length)

      if subject.rdf_type
        @io.write("#{pref} a #{subject.rdf_type}")
        pref = ";\n" + indent
      end

      subject.nodes.each do |predicate|
        objects = predicate.nodes.map { |object|
          object.to_s(indent: indent, lang: predicate.lang || subject.lang || @document_language)
        }.join(", ")
        @io.write("#{pref} #{predicate} #{objects}")
        pref = ";\n" + indent
      end
      @io.write(".\n")
      @io.write("\n") if @config[:empty_line_between_triples]
    end

    # --- N-Triples ---

    def serialize_ntriples(sbj)
      nt_process_subject(sbj) do |triple|
        nt_process_blank_nodes(triple, sbj)
      end
    end

    def nt_process_subject(sbj, &block)
      rdf_type = IqRdf::Rdf::build_uri("type")

      if (sbj.rdf_type rescue false)
        lang = sbj.lang || @document_language
        nt_write_triple([sbj, rdf_type, sbj.rdf_type], lang)
      end

      sbj.nodes.each do |prd|
        lang = prd.lang || sbj.lang || @document_language
        prd.nodes.each do |obj|
          triple = [sbj, prd, obj]
          nt_write_triple(triple, lang)
          block.call(triple) if block
        end
      end
    end

    def nt_process_blank_nodes(triple, current_res)
      sbj, _prd, obj = triple
      [sbj, obj].select { |res| res.is_a?(IqRdf::BlankNode) && res != current_res }.each do |res|
        nt_process_subject(res) do |inner_triple|
          nt_process_blank_nodes(inner_triple, res)
        end
      end
    end

    def nt_write_triple(triple, lang)
      parts = triple.map { |res| nt_resource(res, lang) }
      @io.write("#{parts.join(' ')} .\n")
    end

    def nt_resource(res, lang)
      if res.is_a?(IqRdf::Literal)
        res.to_ntriples(lang)
      elsif res.is_a?(IqRdf::BlankNode)
        nt_blank_node(res)
      elsif res.is_a?(IqRdf::Collection)
        nt_collection(res)
      else
        "<#{res.full_uri}>"
      end
    end

    def nt_blank_node(res)
      @blank_nodes[res] ||= @blank_nodes.size + 1
      "_:b#{@blank_nodes[res]}"
    end

    def nt_collection(res)
      nt_blank_node(res) # register collection object (matches original side-effect)
      list = IqRdf::BlankNode.new
      sublist = list
      total = res.elements.length
      res.elements.each_with_index do |current_element, i|
        last = i + 1 == total
        sublist::rdf.build_predicate("type", IqRdf::Rdf::build_uri("List"))
        sublist::rdf.first(current_element)
        if last
          sublist::rdf.rest(IqRdf::Rdf::build_uri("nil"))
        else
          new_sublist = IqRdf::BlankNode.new
          sublist::rdf.rest(new_sublist)
        end
        nt_process_subject(sublist) { |triple| nt_process_blank_nodes(triple, sublist) }
        sublist = new_sublist unless last
      end
      nt_blank_node(list)
    end

    # --- XML ---

    def write_xml_header
      @xml = Builder::XmlMarkup.new(target: @io, indent: 2)
      @xml.instruct!
      opts = {}
      @namespaces.values.each do |namespace|
        opts[namespace.token == :default ? "xmlns" : "xmlns:#{namespace.token}"] = namespace.uri_prefix
      end
      opts["xml:lang"] = @document_language if @document_language
      # Fiber pausiert den Builder-Block nach dem öffnenden Tag, so dass
      # Builder die Einrückungstiefe korrekt trackt während Nodes gestreamt werden.
      @xml_fiber = Fiber.new { @xml.rdf(:RDF, opts) { Fiber.yield } }
      @xml_fiber.resume
    end

    def serialize_xml(node)
      node.build_xml(@xml)
    end

    def write_xml_footer
      @xml_fiber.resume if @xml_fiber&.alive?
    end

  end
end
