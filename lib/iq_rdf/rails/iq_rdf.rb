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

module ActionView::TemplateHandlers

  class IqRdf < ActionView::TemplateHandler
    include ActionView::TemplateHandlers::Compilable

    def compile(template)
      <<-EOV

      document = IqRdf::Document.new()
      #{template.source}
      if params[:format].to_s == "ttl"
        controller.response.headers["Content-Type"] ||= 'text/turtle'
        document.to_turtle
      elsif  params[:format].to_s == "nt"
        controller.response.headers["Content-Type"] ||= 'text/plain'
        document.to_ntriples
      elsif params[:format].to_s == "rdf"
        controller.response.headers["Content-Type"] ||= 'application/xml+rdf'
        document.to_xml
      else # Default => turtle
        controller.response.headers["Content-Type"] ||= 'text/turtle'
        document.to_turtle
      end
      EOV
    end
  end
  
end
