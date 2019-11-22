module Simple
  class Httpd
    class << self
      attr_accessor :env
    end
  end
end

module Simple::Httpd::CLI
  include Simple::CLI

  # Runs a simple httpd server
  #
  # A mount is either the location of a directory, which would then be mounted
  # at the "/" HTTP location, or a directory followed by a colon and where to mount
  # the directory.
  #
  # Mounted directories might contain either ruby source code which is then executed
  # or static files to be delivered verbatim. See README.md for more details.
  #
  # Examples:
  #
  #   simple-httpd --port=8080 httpd/root --service=src/to/service.rb MyService:/ httpd/assets:assets
  #
  # serves the content of ./httpd/root on http://0.0.0.0/ and the content of httpd/assets
  # on http://0.0.0.0/assets.
  #
  # Options:
  #
  #   --environment=ENV         ... the environment setting, which adjusts configuration.
  #   --services=<path>,<path>  ... load these ruby file during startup. Used to define service objects.
  #
  # simple-httpd respects the HOST and PORT environment values to determine the interface
  # and port to listen to. Default values are "127.0.0.1" and 8181.
  #
  # Each entry in mounts can be either:
  #
  # - a mount_point <tt>[ mount_point, path ]</tt>, e.g. <tt>[ "path/to/root", "/"]</tt>
  # - a string denoting a mount_point, e.g. "path/to/root:/")
  # - a string denoting a "/" mount_point (e.g. "path", which is shorthand for "path:/")
  def main(*mounts, environment: "development", services: nil)
    ::Simple::Httpd.env = environment

    start_simplecov if environment == "test"

    mounts << "." if mounts.empty?

    host = ENV["HOST"] || "127.0.0.1"
    port = Integer(ENV["PORT"] || 8181)

    # late loading simple/httpd, for simplecov support
    require "simple/httpd"

    load_services! services if services
    logger.info "start to listen on #{mounts.inspect}"
    ::Simple::Httpd.listen!(*mounts, environment: environment,
                                          host: host,
                                          port: port)
  end

  def routes(*mounts, environment: "development", services: nil)
    # build the application and print the routes
  end

  private

  def load_services!(paths)
    expect! paths => String

    resolve_service_path(paths).each do |path|
      logger.info "Loading service(s) from #{::Simple::Httpd::Helpers.shorten_path path}"
      load path
    end
  end

  def resolve_service_path(paths)
    # each service_path either denotes the path to a file or to a directory
    # of files.
    paths.split(",").each_with_object([]) do |service_path, ary|
      if Dir.exist?(service_path)
        ary.concat Dir.glob("#{service_path}/**/*.rb").sort
      else
        ary << service_path
      end
    end
  end

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
