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

    private

    def register_namespace(name, uri_prefix)
      (@namespaces ||= {})[name] = IqRdf::Namespace.create(name, uri_prefix)
    end

  end
end