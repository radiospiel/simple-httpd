# rubocop:disable Metrics/AbcSize, Style/ParallelAssignment

require "simple-service"
require_relative "./rack"

class Simple::Httpd::Mount
  def self.build(arg, at:)
    if at
      entity, mount_point = arg, at
    else
      # The regexp below uses negative lookbehind and negative lookahead to
      # only match single colons, but not double (or more) colons. See
      # `ri Regexp` for details.
      entity, mount_point = *arg.split(/(?<!:):(?!:)/, 2)
    end

    mount_point = normalize_and_verify_mount_point(mount_point)

    ServiceMount.build(mount_point, service: entity) ||
      PathMount.build(mount_point, path: entity) ||
      raise(ArgumentError, "#{mount_point}: don't know how to mount #{entity.inspect}")
  end

  def self.normalize_and_verify_mount_point(mount_point)
    mount_point ||= "/"                           # fall back to "/"
    mount_point = File.join("/", mount_point)     # make sure we start at "/"

    canary_url = "http://0.0.0.0#{mount_point}"   # verify mount_point: can it be used to build a URL?
    URI.parse canary_url

    mount_point
  end

  attr_reader :mount_point

  class PathMount < ::Simple::Httpd::Mount
    Rack = ::Simple::Httpd::Rack

    attr_reader :path, :mount_point

    def self.build(mount_point, path:)
      path = path.gsub(/\/$/, "") # remove trailing "/"

      raise ArgumentError, "You probably don't want to mount your root directory, check mount" if path == ""
      return unless Dir.exist?(path)

      new(mount_point, path)
    end

    def initialize(mount_point, path)
      @mount_point, @path = mount_point, path
    end

    def build_rack_apps
      dynamic_mount = Rack::DynamicMount.build(mount_point, path)
      static_mount = Rack::StaticMount.build(mount_point, path)

      [dynamic_mount, static_mount].compact
    end
  end

  class ServiceMount < ::Simple::Httpd::Mount
    H = ::Simple::Httpd::Helpers

    attr_reader :service

    def self.build(mount_point, service:)
      service = ::Simple::Service.resolve(service)
      return unless service

      new(mount_point, service)
    end

    def initialize(mount_point, service)
      @mount_point, @service = mount_point, service
    end

    def build_rack_apps
      [build_controller]
    end

    private

    # wraps all helpers into a Simple::Httpd::BaseController subclass
    def build_controller
      controller = H.subclass(::Simple::Httpd::BaseController, description: "ServiceMount")
      setup_action_routes! controller
      controller
    end

    def setup_action_routes!(controller)
      action_names = service.actions.keys

      controller.mount_service(service) do |service|
        action_names.each do |action_name|
          ::Simple::Httpd.logger.debug "#{mount_point}/#{action_name} -> #{service.name}##{action_name}"
          controller.post "/#{action_name}" => action_name
        end
      end

      ::Simple::Httpd.logger.info do
        "#{mount_point}: mounting #{action_names.count} actions(s) from #{service.name} service"
      end
    end
  end
end
