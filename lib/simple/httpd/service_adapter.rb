require "simple-service"

module Simple::Httpd::ServiceAdapter
  def mount_service(service)
    @service = service

    instance_eval do
      yield(service)
    end
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
      handle_service_route(verb, path, action_name)
    else
      handle_non_service_route(verb, path, opts, &block)
    end
  end

  def handle_service_route(verb, path, action_name)
    # Fetch action (to get a source_location). At the same time this also
    # verifies the existence of this action in the first place.
    action = @service.fetch_action(action_name)

    describe_route!(verb: verb, path: path, source_location: action.source_location)

    # get service reference into binding, to make it available for the route
    # definition's callback block.
    service = @service

    # define sinatra route.
    route(verb, path) do
      result = service.call(action_name, parsed_body, params, context: context)
      encode_result(result)
    end
  end

  def handle_non_service_route(verb, path, opts, &block)
    describe_route!(verb: verb, path: path, source_location: block.source_location) if block

    route(verb, path, opts) do
      result = instance_eval(&block)
      unless headers["Content-Type"]
        result = encode_result(result)
      end
      result
    end
  end

  module Helpers
    def context
      @context ||= ::Simple::Service::Context.new
    end
  end
end

::Simple::Httpd::BaseController.extend(::Simple::Httpd::ServiceAdapter)
::Simple::Httpd::BaseController.helpers(::Simple::Httpd::ServiceAdapter::Helpers)
