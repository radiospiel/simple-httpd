class Simple::Httpd
  module Server
    extend self

    module NullLogger # :nodoc:
      extend self

      def <<(msg); end
    end

    def self.listen!(app, environment: "development", port:, logger: nil)
      expect! app != nil
      expect! port => 80..60_000

      logger ||= ::Simple::Httpd.logger
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
  end
end
