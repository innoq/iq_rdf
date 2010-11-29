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
