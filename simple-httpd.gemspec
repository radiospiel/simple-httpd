# This file is part of the sinatra-sse ruby gem.
#
# Copyright (c) 2016, 2017 @radiospiel, mediapeers Gem
# Distributed under the terms of the modified BSD license, see LICENSE.BSD

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name     = "simple-httpd"
  gem.version  = File.read("VERSION")

  gem.authors  = [ "radiospiel" ]
  gem.email    = "eno@radiospiel.org"
  gem.homepage = "http://github.com/radiospiel/simple-httpd"
  gem.summary  = "Super-simple HTTPD server"

  gem.description = "Super-simple HTTPD server - sinatra w/gimmiks"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths =  %w(lib)

  # executables are used for development purposes only
  gem.executables   = []

  gem.required_ruby_version = '~> 2.5'

  # -- dependencies for postjob httpd
  gem.add_runtime_dependency "neatjson", "~> 0.8.4"
  gem.add_runtime_dependency "sinatra", "~> 2"
  gem.add_runtime_dependency "sinatra-reloader", "~> 1"
  
  # development gems
  gem.add_development_dependency "rspec-httpd", "~> 0.0.14"
  gem.add_development_dependency 'rake', '~> 11'
  gem.add_development_dependency 'rspec', '~> 3.7'
  gem.add_development_dependency 'rubocop', '~> 0.61.1'
  gem.add_development_dependency 'simplecov', '~> 0'
  gem.add_development_dependency 'awesome_print', '~> 0'
end
