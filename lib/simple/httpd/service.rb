require "simple-service"

class Simple::Httpd::Service
  module ControllerAdapter
    def mount_service(service)
      @service = service

      instance_eval do
        yield(service)
      end
    ensure
      @service = nil
    end

    def get(path, opts = {}, &block)
      service_route?("GET", path, opts, &block) || super
    end

    def post(path, opts = {}, &block)
      service_route?("POST", path, opts, &block) || super
    end

    def put(path, opts = {}, &block)
      service_route?("PUT", path, opts, &block) || super
    end

    def delete(path, opts = {}, &block)
      service_route?("DELETE", path, opts, &block) || super
    end

    def head(path, opts = {}, &block)
      service_route?("HEAD", path, opts, &block) || super
    end

    private

    def service_route?(verb, path, opts, &block)
      return false unless @service
      return false if block
      return false unless opts.empty?
      return false unless path.is_a?(Hash) && path.size == 1

      path, action_name = *path.first

      # Verify existence of this action.
      @service.fetch_action(action_name)

      # get service reference into binding, to make it available for the route
      # definition.
      service = @service

      # define sinatra route.
      route(verb, path) do
        result = service.call(action_name, parsed_body, params, context: context)
        json(result)
      end

      true
    end
  end

  module Helpers
    def context
      @context ||= ::Simple::Service::Context.new
    end
  end

  ::Simple::Httpd::BaseController.extend(ControllerAdapter)
  ::Simple::Httpd::BaseController.helpers(Helpers)
end
