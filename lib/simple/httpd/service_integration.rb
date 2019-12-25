# rubocop:disable Lint/RescueException
# rubocop:disable Metrics/AbcSize

require "simple-service"

module Simple::Httpd::ServiceIntegration
  class Adapter
    extend Forwardable

    def initialize(simple_service)
      @simple_service = simple_service
    end

    def action(action_name)
      ::Simple::Service.action(@simple_service, action_name)
    end

    def invoke(name, args: {}, flags: {})
      ::Simple::Service.invoke @simple_service, name, args: args, flags: flags
    end

    def invoke3(name, *args, **flags)
      ::Simple::Service.invoke3 @simple_service, name, *args, **flags
    end
  end

  def mount_service(service)
    @service = Adapter.new(service)
    yield(@service)
  ensure
    @service = nil
  end

  def get(path, opts = {}, &block)
    install_route("GET", path, opts, &block)
  end

  def post(path, opts = {}, &block)
    install_route("POST", path, opts, &block)
  end

  def put(path, opts = {}, &block)
    install_route("PUT", path, opts, &block)
  end

  def delete(path, opts = {}, &block)
    install_route("DELETE", path, opts, &block)
  end

  def head(path, opts = {}, &block)
    install_route("HEAD", path, opts, &block)
  end

  private

  def service_route?(_verb, path, opts, &block)
    return false unless @service
    return false if block
    return false unless opts.empty?
    return false unless path.is_a?(Hash) && path.size == 1

    true
  end

  def install_route(verb, path, opts, &block)
    if service_route?(verb, path, opts, &block)
      path, action_name = *path.first
      install_service_shortcut(verb, path, action_name)
    elsif @service
      install_service_route(verb, path, opts, &block)
    else
      install_non_service_route(verb, path, opts, &block)
    end
  end

  def install_service_shortcut(verb, path, action_name)
    # Fetch action's source_location. This also verifies that the action
    # is defined in the first place.
    action = @service.action(action_name)

    describe_route!(verb: verb, path: path, source_location: action.source_location)

    # get service reference into binding, to make it available for the route
    # definition's callback block.
    service = @service

    # define sinatra route.
    route(verb, path) do
      ::Simple::Service.with_context(context) do
        result = service.invoke(action_name, args: parsed_body, flags: stringified_params)
        encode_result(result)
      rescue Errno::ENOENT => e
        Simple::Httpd.logger.warn e.to_s
        raise
      rescue Exception => e
        Simple::Httpd.logger.warn "#{e}, from\n    #{e.backtrace[0, 10].join("\n    ")}"
        raise
      end
    end
  end

  def install_service_route(verb, path, opts, &block)
    describe_route!(verb: verb, path: path, source_location: block.source_location) if block

    route(verb, path, opts) do
      ::Simple::Service.with_context(context) do
        result = instance_eval(&block)
        unless headers["Content-Type"]
          result = encode_result(result)
        end
        result
      rescue Errno::ENOENT => e
        Simple::Httpd.logger.warn e.to_s
        raise
      rescue Exception => e
        Simple::Httpd.logger.warn "#{e}, from\n    #{e.backtrace[0, 10].join("\n    ")}"
        raise
      end
    end
  end

  def install_non_service_route(verb, path, opts, &block)
    describe_route!(verb: verb, path: path, source_location: block.source_location) if block

    route(verb, path, opts) do
      instance_eval(&block)
    end
  end

  module Helpers
    def stringified_params
      params.each_with_object({}) do |(k, v), hsh|
        hsh[k.to_s] = v
      end
    end

    def context
      # We return nil here. nil *is* a valid value for Simple::Service.with_context.
      # Important is that with_context is being called.
      nil
    end
  end
end

::Simple::Httpd::BaseController.extend(::Simple::Httpd::ServiceIntegration)
::Simple::Httpd::BaseController.helpers(::Simple::Httpd::ServiceIntegration::Helpers)
