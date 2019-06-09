module Simple
end

module Simple::Httpd
end

require "simple/httpd/version"
require "simple/httpd/app"
require "simple/httpd/base_controller"

module Simple::Httpd
  extend self

  def build_rack(base_controller, logger:)
    App.new(base_controller, logger: logger)
  end

  def listen!(app, environment:, port:)
    expect! port => 80..60_000

    logger = app.logger
    logger.info "Starting httpd server on http://0.0.0.0:#{port}/"

    app = Rack::Lint.new(app) if environment != "production"

    # re/AccessLog: the AccessLog setting points WEBrick's access logging to the
    # NullLogger object.
    #
    # Instead we'll use a combination of Rack::CommonLogger (see Simple::Httpd.app),
    # and sinatra's logger (see Simple::Httpd::BaseController).
    Rack::Server.start app: app,
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
