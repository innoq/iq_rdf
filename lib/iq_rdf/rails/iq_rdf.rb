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

def IqRdf.rails_template(template, source = nil)
  source ||= template.source

  <<-EOV
  document = IqRdf::Document.new()
  #{source}
  if params[:format].to_s == "ttl"
    controller.response.headers["Content-Type"] ||= 'text/turtle;charset=utf-8'
    document.to_turtle
  elsif  params[:format].to_s == "nt"
    controller.response.headers["Content-Type"] ||= 'text/plain;charset=utf-8'
    document.to_ntriples
  elsif params[:format].to_s == "rdf"
    controller.response.headers["Content-Type"] ||= 'application/xml+rdf;charset=utf-8'
    document.to_xml
  else # Default => turtle
    controller.response.headers["Content-Type"] ||= 'text/turtle;charset=utf-8'
    document.to_turtle
  end
  EOV
end

module ActionView

  if Rails.version >= "6"
    class Template::Handlers::IqRdf
      # see https://github.com/rails/rails/commit/28f88e0074f473f58c2d3fd54cb3daff81027c12
      def self.call(template, source)
        IqRdf.rails_template(template, source)
      end
    end
    ActionView::Template.register_template_handler('iqrdf', ActionView::Template::Handlers::IqRdf)

  elsif Rails.version >= "3"

    class Template::Handlers::IqRdf
      def self.call(template)
        IqRdf.rails_template(template)
      end
    end
    ActionView::Template.register_template_handler('iqrdf', ActionView::Template::Handlers::IqRdf)

  else

    class TemplateHandlers::IqRdf < ActionView::TemplateHandler
      include ActionView::TemplateHandlers::Compilable
      def compile(template)
        IqRdf.rails_template(template)
      end
    end
    ActionView::Template.register_template_handler('iqrdf', ActionView::TemplateHandlers::IqRdf)

  end


end
