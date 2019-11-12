class Simple::Httpd
  module Server
    extend self

    module NullLogger # :nodoc:
      extend self

      def <<(msg); end
    end

    def listen!(app, environment: "development", host: nil, port:, logger: nil)
      expect! app != nil

      host ||= "127.0.0.1"
      URI("http://#{host}:#{port}") # validate host and port

      logger ||= ::Simple::Httpd.logger
      logger.info "Starting httpd server on http://#{host}:#{port}/"

      app = ::Rack::Lint.new(app) if environment != "production"

      # re/AccessLog: the AccessLog setting points WEBrick's access logging to the
      # NullLogger object.
      #
      # Instead we'll use a combination of Rack::CommonLogger (see Simple::Httpd.app),
      # and sinatra's logger (see Simple::Httpd::BaseController).
      ::Rack::Server.start app: app,
                           Host: host,
                           Port: port,
                           environment: environment,
                           Logger: logger,
                           AccessLog: [[NullLogger, ""]]
    end
  end
end
