module Simple::Service
  class ArgumentError < ::ArgumentError
  end
end

require_relative "service/action"
require_relative "service/context"

module Simple::Service
  def self.included(klass)
    klass.extend ClassMethods
  end

  def self.context
    Thread.current[:"Simple::Service.context"]
  end

  def self.with_context(ctx)
    old_ctx = Thread.current[:"Simple::Service.context"]
    Thread.current[:"Simple::Service.context"] = ctx
    yield
  ensure
    Thread.current[:"Simple::Service.context"] = old_ctx
  end

  module ClassMethods
    def actions
      @actions ||= Action.build_all(service_module: self)
    end

    def build_service_instance
      service_instance = Object.new
      service_instance.extend self
      service_instance
    end

    def fetch_action(action_name)
      actions.fetch(action_name) do
        informal = "service #{self} has these actions: #{actions.keys.sort.map(&:inspect).join(", ")}"
        raise "No such action #{action_name.inspect}; #{informal}"
      end
    end

    def call(action_name, arguments, params, context: nil)
      ::Simple::Service.with_context(context) do
        fetch_action(action_name).invoke(arguments, params)
      end
    end
  end

  # Resolves a service by name. Returns nil if the name does not refer to a service,
  # or the service module otherwise.
  def self.resolve(str)
    return unless str =~ /^[A-Z][A-Za-z0-9_]*(::[A-Z][A-Za-z0-9_]*)*$/

    service = resolve_constant(str)

    return unless service.is_a?(Module)
    return unless service.include?(::Simple::Service)

    service
  end

  def self.resolve_constant(str)
    const_get(str)
  rescue NameError
    nil
  end
end
