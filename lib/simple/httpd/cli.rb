module Simple
  class Httpd
  end
end

module Simple::Httpd::CLI
  include Simple::CLI

  def self.run!(*args)
    # By passing in "main" we don't run subcommands.
    super "main", *args
  end

  # Run a simple httpd server
  def main(path, *paths, port: 8018, environment: "development")
    start_simplecov if environment == "test"

    port = Integer(port)

    # late loading simple/httpd, for simplecov support
    require "simple/httpd"

    ::Simple::Httpd.listen!(path, *paths, environment: environment,
                                          port: port,
                                          logger: logger)
  end

  private

  def stderr_logger
    logger = ::Logger.new STDERR
    logger.level = ::Logger::INFO
    logger
  end

  def start_simplecov
    require "simplecov"

    SimpleCov.command_name "Integration Tests"
    SimpleCov.start do
      # return true to remove src from coverage
      add_filter do |src|
        next true if src.filename =~ /\/spec\//

        false
      end

      # minimum_coverage 90
    end
  end
end
