# rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize

class Simple::Httpd
  module Server
    extend self

    module NullLogger # :nodoc:
      extend self

      def <<(msg); end
    end

    def listen!(app, environment: "development", host: nil, port:)
      expect! app != nil

      host ||= "127.0.0.1"
      URI("http://#{host}:#{port}") # validate host and port

      ::Simple::Httpd.logger.info "Starting httpd server on http://#{host}:#{port}/"

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
                           Logger: build_logger,
                           AccessLog: [[NullLogger, ""]]
    end

    private

    def build_logger
      # We create a fresh STDERR logger. The log level is taken from Simple::Httpd -
      # but is at maximum :info, since we don't want to log internals of Webrick & co.
      #
      # (Note that our own services would probably use ::Simple::Httpd.logger, which
      # sticks at the current level.)
      if ::Simple::Httpd.custom_logger?
        logger = ::Simple::Httpd.logger
      else
        log_level = ::Simple::Httpd.logger.debug? ? :info : ::Simple::Httpd.logger.level
        logger = ::Logger.new STDERR, level: log_level
      end

      # When Webrick is being shut down via SIGTERM - which we do at least during
      # rspec-httpd triggered runs - it sends a fatal message to the logger. We catch
      # it - to "downgrade" it to INFO - but we still abort.
      def logger.fatal(msg, &block)
        if msg.is_a?(SignalException) && msg.signo == ::Signal.list["TERM"]
          env = ::Simple::Httpd.env
          if %w(test development).include?(env)
            ::Simple::Httpd.logger.info "Received SIGTERM: hard killing server (due to running in #{env.inspect} environment)"
            ::Simple::Httpd::Server.send :exit!
          else
            ::Simple::Httpd.logger.info "Received SIGTERM: shutting down server..."
            exit 1
          end
        end

        super
      end

      logger
    end

    def exit!(exit_status = 1)
      # Run SimpleCov if exists, and if this is the PID that started SimpleCov in the first place.
      if defined?(SimpleCov) && SimpleCov.pid == Process.pid
        SimpleCov.process_result(SimpleCov.result, 0)
      end

      Kernel.exit! exit_status
    end
  end
end
