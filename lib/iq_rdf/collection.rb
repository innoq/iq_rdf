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

  end
end
