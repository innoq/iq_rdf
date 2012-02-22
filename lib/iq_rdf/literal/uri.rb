module IqRdf
  class Literal
    class URI < Literal

      def initialize(uri)
        raise "#{uri.inspect} is not an URI" unless uri.is_a?(::URI)
        super(uri)
      end

      def to_s(parent_lang = nil)
        "<#{@obj.to_s}>"
      end

      def build_xml(xml, &block)
        block.call("rdf:resource" => @obj.to_s)
      end

    end
  end
end