# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "NIFTY/version"

Gem::Specification.new do |s|
  s.name        = "nifty-cloud-sdk"
  s.version     = NIFTY::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["NIFTY Corporation"]
  s.homepage    = "http://cloud.nifty.com/api/"
  s.summary     = "NIFTY Cloud SDK for Ruby"
  s.description = "It is an operation library for Nifty Cloud APIs that the server making, starting, stoping, and the server status confirming etc."

  s.rdoc_options = ["--title", "NIFTY Cloud SDK documentation", "--line-numbers", "--main", "README.rdoc", "-c", "UTF-8"]
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc"]

  s.add_dependency('xml-simple', '>= 1.0.12')
  s.add_development_dependency('mocha', '>= 0.9.9')
  s.add_development_dependency('test-unit', '>= 2.1.2')
  s.add_development_dependency('test-spec', '>= 0.10.0')
  s.add_development_dependency('rcov', '>= 0.9.9')
  s.add_development_dependency('perftools.rb', '>= 0.5.4')
  s.add_development_dependency('yard', '>= 0.6.2')

  s.files         = Dir['Gemfile', 'Rakefile', 'nifty-cloud-sdk.gemspec', 'LICENSE.txt', 'INSTALL', 'CHANGELOG', 'README.rdoc',  'lib/**/*.rb', 'sample/**/*.rb', 'test/*.rb']
  s.test_files    = Dir['test/*.rb']
  s.require_paths = ["lib"]
end
