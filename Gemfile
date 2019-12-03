source 'https://rubygems.org'

# Specify your gem's dependencies in {gemname}.gemspec
gemspec

# --- Local overrides for runtime dependencies ------------------------------

# gem "simple-cli", path: "../simple-cli"
# gem "simple-service", path: "../simple-service"

# --- Development and test dependencies ------------------------------

group :development, :test do
  gem "rspec-httpd", "~> 0.3.2"
  # gem "rspec-httpd", path: "../rspec-httpd"
  # # gem "simple-http", path: "../simple-http"

  gem 'rake', '~> 11'
  gem 'rspec', '~> 3.7'
  # gem 'rubocop', '~> 0.61.1'
  gem 'simplecov', '~> 0'
  gem 'byebug'

  ENV["PRELOAD_GEMS"].to_s.split(",").each do |gem_name|
    gem gem_name
  end
end
