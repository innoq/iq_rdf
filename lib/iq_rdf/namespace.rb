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
  class Namespace

    # Methods used in child classes

    def self.token
      self.instance_variable_get(:@token)
    end

    def self.uri_prefix
      self.instance_variable_get(:@uri_prefix)
    end

    def self.turtle_token
      self.token != :default ? self.token.to_s : ""
    end

    def self.build_uri(postfix, type = nil, &block)
      uri = IqRdf::Uri.new(self, postfix, type)
      if block
        yield(uri)
      end
      uri
    end

    # Namespace only methods
    
    def self.create(token, uri_prefix)
      klass_name = self.class_name(token)
      klass = IqRdf.const_defined?(klass_name) ? IqRdf.const_get(klass_name) : IqRdf.const_set(klass_name, Class.new(self))
      klass.instance_variable_set(:@token, token)
      klass.instance_variable_set(:@uri_prefix, uri_prefix)
      klass
    end

    def self.find_namespace_class(token)
      klass_name = self.class_name(token)
      IqRdf.const_get(klass_name) if IqRdf.const_defined?(klass_name)
    end

    def self.dummy_empty_namespace
      @dummy_empty_namespace ||= Class.new(self)
    end

    protected

    def self.method_missing(method_name, *args, &block)
      type = args.shift if args[0].is_a?(IqRdf::Uri)
      self.build_uri(method_name, type, &block)
    end

    def self.class_name(name)
      name.to_s.gsub(/(^|_)(.)/) { $2.upcase }
    end
  
  end
end