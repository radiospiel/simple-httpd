require "simple-service"

module Simple::Httpd::ServiceAdapter
  def mount_service(service)
    @service = service

    instance_eval do
      def dispatch!
        ::Simple::Service.with_context(context)
        super
      ensure
        ::Simple::Service.context = nil
      end

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
    # Fetch action's source_location. This also verifies that the action
    # is defined in the first place.
    action = ::Simple::Service.action(@service, action_name)

    describe_route!(verb: verb, path: path, source_location: action.source_location)

    # get service reference into binding, to make it available for the route
    # definition's callback block.
    service = @service

    # define sinatra route.
    route(verb, path) do
      ::Simple::Service.with_context(context) do
        # [TODO] - symbolizing keys opens up this for DDOS effects.
        # THIS MUST BE FIXED IN simple-service.
        flags = self.params.inject({}) { |hsh, (k,v)| hsh.update k.to_sym => v }
        args = self.parsed_body.inject({}) { |hsh, (k,v)| hsh.update k.to_sym => v }

        result = ::Simple::Service.invoke2(service, action_name, args: args, flags: flags)
        encode_result(result)
      end
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
      # We return nil here. nil *is* a valid value for Simple::Service.with_context.
      # Important is that with_context is being called.
      nil
    end
  end
end

::Simple::Httpd::BaseController.extend(::Simple::Httpd::ServiceAdapter)
::Simple::Httpd::BaseController.helpers(::Simple::Httpd::ServiceAdapter::Helpers)
