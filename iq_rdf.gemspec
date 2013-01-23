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

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "iq_rdf/version"

Gem::Specification.new do |s|
  s.name        = "iq_rdf"
  s.version     = IqRdf::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Till Schulte-Coerne"]
  s.email       = ["till.schulte-coerne@innoq.com"]
  s.homepage    = "http://github.com/innoq/iq_rdf"
  s.summary     = "IqRdf - A builder like rdf library for ruby and rails"
  s.description = s.summary
  s.extra_rdoc_files = ['README.md', 'LICENSE']

  s.add_dependency "bundler"
  s.add_dependency "builder"
  s.add_dependency "active_support"

  s.files = %w(LICENSE README.md Rakefile iq_rdf.gemspec) + Dir.glob("{lib,rails,test}/**/*")
  s.test_files = Dir.glob("{test}/**/*")
  s.executables = Dir.glob("{bin}/**/*")
  s.require_paths = ["lib"]
end
