module IqRdf
  class Literal

    def initialize(obj, lang = nil)
      @obj = obj
      @lang = lang
    end

    def to_s(lang = nil)
      lang = @lang || lang # Use the Literals lang when given
      if @obj.is_a?(URI)
        "<#{@obj.to_s}>"
      elsif @obj === true
        "true"
      elsif @obj === false
        "false"
      elsif @obj.is_a?(Numeric)
        @obj.to_s
      else
        quote = @obj.to_s.include?("\n") ? '"""' : '"'
        "#{quote}#{@obj.to_s.gsub("\\", "\\\\\\\\").gsub(/"/, "\\\"")}#{quote}#{(lang && lang != :none) ? "@#{lang}" : ""}"
      end
    end

    def build_xml(xml, &block)
      if @obj.is_a?(URI)
        block.call("rdf:resource" => @obj.to_s)
      else
        opts = {}
        { Integer => "http://www.w3.org/2001/XMLSchema#integer",
          Float => "http://www.w3.org/2001/XMLSchema#decimal",
          TrueClass => "http://www.w3.org/2001/XMLSchema#boolean",
          FalseClass => "http://www.w3.org/2001/XMLSchema#boolean",
        }.each do |klass, s|
          opts["rdf:datatype"] = s if @obj.is_a?(klass)
        end
        opts["xml:lang"] = @lang if @lang
        block.call(@obj.to_s, opts)
      end
    end

    alias_method :full_uri, :to_s

  end
end
