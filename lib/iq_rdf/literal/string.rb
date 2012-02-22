module IqRdf
  class Literal
    class String < Literal

      def initialize(s, lang = nil)
        raise "#{s.inspect} is not a String" unless s.is_a?(::String)
        super(s, lang)
      end

    end
  end
end