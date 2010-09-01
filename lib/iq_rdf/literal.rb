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
        "\"#{@obj.to_s.gsub(/"/, "\\\"")}\"#{(lang && lang != :none) ? "@#{lang}" : ""}"
      end
    end

    alias_method :full_uri, :to_s

  end
end
