class Simple::Httpd
  module Server
    extend self

    module NullLogger # :nodoc:
      extend self

      def <<(msg); end
    end

    def self.listen!(app, environment: "development", host:, port:, logger: nil)
      expect! app != nil
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
