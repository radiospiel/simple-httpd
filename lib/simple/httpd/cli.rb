module Simple
  module Httpd
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
    Simple::Httpd.logger = Simple::CLI.logger

    # build and start app
    mounts = ([path] + paths).map do |s|
      extract_mountpoint_and_path(s)
    end

    app = Simple::Httpd.build(mounts)
    ::Simple::Httpd.listen! app, environment: environment,
                                 port: port,
                                 logger: httpd_logger(environment: environment)
  end

  private

  def extract_mountpoint_and_path(str)
    path, mountpoint = str.split(":", 2)
    path = path.gsub(/\/$/, "")

    # Fall back to "/"
    mountpoint ||= "/"

    # make sure mountpoint starts with "/"
    mountpoint = File.join("/", mountpoint)
    [mountpoint, path]
  end

  def httpd_logger(environment:)
    return logger unless environment == "test"

    test_logger
  end

  def test_logger
    logger = ::Logger.new STDERR
    logger.level = ::Logger::INFO
    def logger.fatal(msg, *)
      STDERR.puts "#{msg} exiting..." if msg.to_s != "SIGTERM"
      exit 1
    end
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
