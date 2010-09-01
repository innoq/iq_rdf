# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "iq_rdf"
  s.version     = "0.0.6"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Till Schulte-Coerne"]
  s.email       = ["till.schulte-coerne@innoq.com"]
  s.homepage    = "http://innoq.com"
  s.summary     = ""
  s.description = ""

  s.required_rubygems_version = ">= 1.3.6"

  # s.rubyforge_project = "-"

  # s.add_dependency "activerecord"
  # s.add_dependency "actionpack"
  # s.add_dependency "typhoeus"
  # s.add_dependency "json"

  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README)
  s.executables  = []
end
