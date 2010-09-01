require 'iq_rdf'
require 'iq_rdf/rails/rdf'

ActionView::Template.register_template_handler 'rdf', ActionView::TemplateHandlers::RDF
