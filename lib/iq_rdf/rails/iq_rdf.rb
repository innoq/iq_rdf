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
      else
        controller.response.headers["Content-Type"] ||= 'text/turtle'
        document.to_turtle # TODO: This should be to_xml, when implemented!
      end
      EOV
    end
  end
  
end
