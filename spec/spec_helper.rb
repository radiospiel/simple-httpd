ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"

require "byebug"
require "rspec"
require "rspec-httpd"

RSpec::Httpd.configure do |config|
  config.host = "127.0.0.1"
  config.port = 12_345
  config.command = "bin/simple-httpd --environment=test --port=12345 examples/ex1 examples/ex2"
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
