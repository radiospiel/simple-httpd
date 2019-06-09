class Simple::Httpd::App
end

require_relative "app/file_server"

# The Simple::Httpd::App implements a Rack compatible app, which serves
# HTTP requests via a set of controllers inherited from a base controller
# class.
#
# The individual routes are determined from the controller class names:
# assuming we have a controller class Foo::Bar::BazController inheriting
# from Foo::BaseController will serve the /bar/baz routes.
#
# Additional static routes can be configured by calling "mount_directory!!"
# on the app object.
class Simple::Httpd::App
  extend Forwardable
  delegate call: :@app

  attr_reader :logger

  #
  # Builds a App object
  def initialize(base_controller, logger:)
    raise unless logger

    @base_controller = base_controller
    @logger = logger
    @file_mounts = []

    @app = Rack::URLMap.new(controllers_url_map)
  end

  def mount_directory!(url:, path:)
    @logger.debug "#{path}: mount directory #{path}"
    @app = FileServer.new(@app, url_prefix: url, root: path)
  end

  private

  # Find all controllers inheriting off base_controller and return
  # a URL map, based on the names of the controllers.
  def controllers_url_map
    controller_by_mountpoint = ObjectSpace
                               .each_object(Class)
                               .select { |klass| klass < @base_controller }
                               .map { |controller| [mountpoint(controller), controller] }
                               .reject { |mountpoint, _controller| mountpoint.nil? }

    controller_by_mountpoint
      .sort_by { |path, _controller| path }
      .each { |path, controller| logger.debug "#{path}: mount #{controller}" }

    Hash[controller_by_mountpoint]
  end

  def mountpoint(controller)
    return unless controller.name.end_with?("Controller")

    relative_controller_name = relative_controller_name(controller)
    return "/" if relative_controller_name == "RootController"

    "/" + relative_controller_name.underscore.gsub(/_controller$/, "")
  end

  # With a controller of Postjob::FooBarController returns FooBarController
  # (depending on the base_controller)
  def relative_controller_name(controller)
    controller_name = controller.name
    if controller_name.start_with?(base_controller_namespace)
      controller_name[base_controller_namespace.length..-1]
    else
      controller_name
    end
  end

  # With a base_controller of Postjob::BaseController this returns "Postjob"
  def base_controller_namespace
    @base_controller_namespace ||= begin
      base_controller_name = @base_controller.name
      base_controller_name.gsub(/::BaseController$/, "::")
    end
  end
end
