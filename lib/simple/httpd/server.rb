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

      prepare_logger!(logger)
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

    private

    # When Webrick is being shut down via SIGTERM - which we do at least during
    # rspec-httpd triggered runs - it sends a fatal message to the logger. We catch
    # it - to "downgrade" it to INFO - but we still abort.
    def prepare_logger!(logger)
      def logger.fatal(msg, &block)
        if msg.is_a?(SignalException) && msg.signo == ::Signal.list["TERM"]
          if %w(test development).include?(::Simple::Httpd.env)
            info "Received SIGTERM: hard killing server (due to running in #{::Simple::Httpd.env.inspect} environment)"
            Simple::Httpd::Server.exit!
          else
            info "Received SIGTERM: shutting down server..."
            exit 1
          end
        end

        super
      end
    end

    public

    def exit!(exit_status = 1)
      # Run SimpleCov if exists, and if this is the PID that started SimpleCov in the first place.
      if defined?(SimpleCov) && SimpleCov.pid == Process.pid
        SimpleCov.process_result(SimpleCov.result, 0)
      end

      Kernel.exit! exit_status
    end
  end
end
