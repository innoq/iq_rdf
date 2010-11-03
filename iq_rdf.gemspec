# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "iq_rdf/version"

Gem::Specification.new do |s|
  s.name        = "iq_rdf"
  s.version     = IqRdf::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Till Schulte-Coerne"]
  s.email       = ["till.schulte-coerne@innoq.com"]
  s.homepage    = "http://innoq.com"
  s.summary     = "IqRdf - A builder like rdf library for ruby and rails"
  s.description = s.summary
  s.extra_rdoc_files = ['README', 'LICENSE']
  
  s.add_dependency "activerecord"
  s.add_dependency "rails"
  s.add_dependency "bundler"

  s.files = %w(LICENSE README Rakefile) + Dir.glob("{lib,rails,test}/**/*")
  s.files = Dir.glob("{test}/**/*")
  s.files = Dir.glob("{bin}/**/*")
  s.require_paths = ["lib"]
end
