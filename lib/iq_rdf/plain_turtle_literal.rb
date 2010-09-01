module IqRdf
  # This is a dummy class for some needs where
  class PlainTurtleLiteral < Literal

    def initialize(obj)
      @obj = obj
    end

    def to_s(lang = nil)
      @obj.to_s
    end

    alias_method :full_uri, :to_s

  end
end