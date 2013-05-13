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
  class PredicateNamespace

    def initialize(subject, namespace)
      @subject = subject
      @predicate_namespace = namespace
    end

    def build_predicate(postfix, *args, &block)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      objects = args
      predicate = IqRdf::Predicate.new(@predicate_namespace, postfix, @subject, options[:lang])
      if (block)
        raise ArgumentError, "A predicate may either have arguments or a block, or both." if objects.size > 0
        blank_node = IqRdf::BlankNode.new
        yield blank_node
        predicate << blank_node
      else
        return nil if options[:suppress_if_empty] === true && objects.size == 0
        raise ArgumentError, "At least one object is required in predicate call" if objects.size == 0
        objects.each do |o|
          if o.is_a?(Array)
            return nil if options[:suppress_if_empty] === true && o.size == 0
            o = IqRdf::Collection.new(o)
          elsif o.is_a?(IqRdf::Node)
            raise ArgumentError, "Objects may not have nested triples in this Implementation of RDF" if o.is_subject?
          elsif o.is_a?(Literal)
            # We're already done
          elsif o.is_a?(Symbol)
            o = IqRdf::Default.build_uri(o)
          else
            return nil if options[:suppress_if_empty] === true && (o.nil? || o === "")
            o = Literal.build(o)
          end
          predicate << o
        end
      end
      @subject << predicate
      @subject
    end

    protected

    def method_missing(method_name, *args)
      build_predicate(method_name, *args)
    end

  end
end
