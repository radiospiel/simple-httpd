source 'https://rubygems.org'

# Specify your gem's dependencies in {gemname}.gemspec
gemspec

# gem "rspec-httpd", "~> 0.0.14"
gem "rspec-httpd", path: "../rspec-httpd"
gem "simple-cli", path: "../simple-cli"
gem 'rake', '~> 11'
gem 'rspec', '~> 3.7'
# gem 'rubocop', '~> 0.61.1'
gem 'simplecov', '~> 0'
gem 'byebug'

if ENV["PRELOAD_SERVER_GEM"]
  gem ENV["PRELOAD_SERVER_GEM"]
end
