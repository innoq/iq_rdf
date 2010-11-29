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

    def to_s(parent_lang = nil)
      if namespace.token # There is a dummy_empty_namespace without token => postfix is a full uri!
        "#{namespace.turtle_token}:#{self.uri_postfix.to_s}"
      else
        "<#{self.uri_postfix.to_s}>"
      end
    end

    def is_subject?()
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

  end
end