module IqRdf
  class Literal
    class Numeric < Literal

      def initialize(num)
        raise "#{num.inspect} is not a Numeric!" unless num.is_a?(::Numeric)
        super(num, nil, ::URI.parse(num.is_a?(Integer) ? "http://www.w3.org/2001/XMLSchema#integer" : "http://www.w3.org/2001/XMLSchema#decimal"))
      end

      def to_s(parent_lang = nil)
        @obj.to_s
      end

    end
  end
end