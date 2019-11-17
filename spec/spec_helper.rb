ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"

require "byebug"
require "rspec"
require "rspec-httpd"

if ENV["PRELOAD_SERVER_GEM"]
  require ENV["PRELOAD_SERVER_GEM"]
end

# You can comment parts of the command below by prepending the line with a '#'
HTTPD_COMMAND = <<~CMD
  PORT=12345
  bin/simple-httpd
  --environment=test
  examples/ex1
  examples/ex2
  examples/ex3
  examples/v2:api/v2
  --services=examples/services
  Example::Service:service/example
#  2> log/test.log
CMD

RSpec::Httpd.configure do |config|
  config.host = "127.0.0.1"
  config.port = 12_345

  # remove commented parts from HTTPD_COMMAND
  config.command = HTTPD_COMMAND.split(/\s*\n\s*/m).grep(/^\s*[^#]/).join(" ")
end

Dir.glob("./spec/support/**/*.rb").sort.each { |path| load path }

require "simple/httpd"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run focus: (ENV["CI"] != "true")
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = "random"
  config.example_status_persistence_file_path = ".rspec.data"

  config.backtrace_exclusion_patterns << /spec\/support/
  config.backtrace_exclusion_patterns << /spec_helper/
  config.backtrace_exclusion_patterns << /database_cleaner/

  config.include ::RSpec::Httpd

  # config.around(:each) do |example|
  #   example.run
  # end
end
