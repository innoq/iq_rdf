module IqRdf
  class Literal
    class Boolean < Literal

      def initialize(b)
        super(!!b, nil, ::URI.parse("http://www.w3.org/2001/XMLSchema#boolean"))
      end

      def to_s(parent_lang = nil)
        @obj.to_s
      end

    end
  end
end