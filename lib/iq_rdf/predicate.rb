module IqRdf
  class Predicate < Uri

    attr_reader :subject

    def initialize(namespace, uri_postfix, subject, lang = nil)
      super(namespace, uri_postfix, nil, lang)
      @subject = subject
    end

  end
end
