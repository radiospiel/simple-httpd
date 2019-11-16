source 'https://rubygems.org'

# Specify your gem's dependencies in {gemname}.gemspec
gemspec

# --- Local overrides for runtime dependencies ------------------------------

# gem "simple-cli", path: "../simple-cli"

# --- Development and test dependencies ------------------------------

group :development, :test do
  gem "rspec-httpd", "~> 0.3.0"
  # gem "rspec-httpd", path: "../rspec-httpd"

  gem 'rake', '~> 11'
  gem 'rspec', '~> 3.7'
  # gem 'rubocop', '~> 0.61.1'
  gem 'simplecov', '~> 0'
  gem 'byebug'

  if ENV["PRELOAD_SERVER_GEM"]
    gem ENV["PRELOAD_SERVER_GEM"]
  end
end
