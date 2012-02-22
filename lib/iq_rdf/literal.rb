#   Copyright 2011 innoQ Deutschland GmbH
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

module IqRdf
  class Literal

    def initialize(obj, lang = nil, datatype = nil)
      raise "#{datatype.inspect} is not an URI" unless datatype.nil? || datatype.is_a?(::URI) || datatype.is_a?(IqRdf::Uri)
      @obj = obj
      @datatype = datatype
      @lang = lang
    end

    def self.build(o)
      if o.is_a?(::URI)
        IqRdf::Literal::URI.new(o)
      elsif o === true || o === false
        IqRdf::Literal::Boolean.new(o)
      elsif o.is_a?(::Numeric)
        IqRdf::Literal::Numeric.new(o)
      else
        IqRdf::Literal::String.new(o)
      end
    end

    def to_s(parent_lang = nil)
      lang = @lang || parent_lang # Use the Literals lang when given
      lang = (lang && lang != :none) ? "@#{lang}" : ""
      quote = @obj.to_s.include?("\n") ? '"""' : '"'
      datatype = if @datatype.is_a?(::URI)
        "^^<#{@datatype.to_s}>"
      elsif @datatype.is_a?(IqRdf::Uri)
        "^^#{@datatype.to_s}"
      else
        ""
      end

      "#{quote}#{@obj.to_s.gsub("\\", "\\\\\\\\").gsub(/"/, "\\\"")}#{quote}#{lang}#{datatype}"
    end

    def build_xml(xml, &block)
      opts = {}
      if @datatype.is_a?(::URI)
        opts["rdf:datatype"] = @datatype.to_s
      elsif @datatype.is_a?(IqRdf::Uri)
        opts["rdf:datatype"] = @datatype.full_uri
      end
      opts["xml:lang"] = @lang if @lang
      block.call(@obj.to_s, opts)
    end

    alias_method :full_uri, :to_s

  end
end
