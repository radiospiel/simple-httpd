module Simple
end

module Simple::Httpd
end

require "simple/httpd/version"
require "simple/httpd/base_controller"
require "simple/httpd/rack"

module Simple::Httpd
  extend self

  attr_accessor :logger

  # Builds a Simple::Httpd application.
  #
  # mounts is an array with these entries
  #
  # [
  # .   [ mountpoint, path ],
  # .   [ mountpoint, path ],
  # ]
  def build(mounts)
    mounts_by_mountpoint = mounts.each_with_object({}) do |(mountpoint, path), hsh|
      hsh[mountpoint] ||= []
      hsh[mountpoint] << path
    end

    uri_map = {}

    mounts_by_mountpoint.map do |mountpoint, paths|
      apps = paths.inject([]) do |ary, path|
        ary << Rack.dynamic_mount(mountpoint, path)
        ary << Rack.static_mount(mountpoint, path)
      end.compact

      uri_map[mountpoint] = Rack.merge(apps)
    end

    ::Rack::URLMap.new(uri_map)
  end

  def listen!(app, environment:, port:, logger:)
    expect! port => 80..60_000

    logger.info "Starting httpd server on http://0.0.0.0:#{port}/"

    app = ::Rack::Lint.new(app) if environment != "production"

    # re/AccessLog: the AccessLog setting points WEBrick's access logging to the
    # NullLogger object.
    #
    # Instead we'll use a combination of Rack::CommonLogger (see Simple::Httpd.app),
    # and sinatra's logger (see Simple::Httpd::BaseController).
    ::Rack::Server.start app: app,
                         Port: port,
                         environment: environment,
                         Logger: logger,
                         AccessLog: [[NullLogger, ""]]
  end

  module NullLogger # :nodoc:
    extend self

    def <<(msg); end
  end
end
