# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

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

  # dependencies
  gem.add_dependency "neatjson", "~> 0.8.4"
  gem.add_dependency "sinatra", "~> 2"
  # gem.add_dependency "sinatra-reloader", "~> 1"
  gem.add_dependency "expectation", "~> 1"
  gem.add_dependency "simple-cli", "~> 0.3.0"
  gem.add_dependency "simple-service", "~> 0.1.0"
end
#require "expectation"
