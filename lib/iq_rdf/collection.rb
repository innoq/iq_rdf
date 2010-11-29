module IqRdf
  class Collection

    attr_reader :elements

    def initialize(collection)
      @elements = []
      collection.each do |element|
        element = Literal.new(element) unless element.is_a?(IqRdf::Uri)
        @elements << element
      end
    end

    def to_s(lang = nil)
      "(#{@elements.map{|e| e.to_s(lang)}.join(" ")})"
    end

    def build_xml(xml, elements = nil, &block)
      elements ||= @elements.dup
      block.call({},
        lambda {
          xml.rdf :List do
            elements.shift.build_xml(xml) do |*args|
              xml.rdf(:first, *args)
            end
            if elements.size > 0
              build_xml(xml, elements) do |opts, block|
                xml.rdf :rest, &block
              end
            else
              xml.rdf :rest, "rdf:resource" => Rdf.nil.full_uri
            end
          end
        }
      )
    end

  end
end
