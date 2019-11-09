require_relative "./rack"

class Simple::Httpd::MountSpec
  def self.build(arg, at:)
    case arg
    when String
      if at
        PathMountSpec.new path: mount_spec, mount_point: at
      else
        path, mount_point = *arg.split(":", 2)
        PathMountSpec.new path: path, mount_point: mount_point
      end
    when Module
      ServiceMount.new arg, mount_point: at
    end
  end

  attr_reader :mount_point

  class PathMountSpec < ::Simple::Httpd::MountSpec
    attr_reader :path, :mount_point

    def initialize(path:, mount_point:)
      @path        = normalize_and_verify_path! path
      @mount_point = normalize_and_verify_mount_point! mount_point
    end

    def build_rack_apps
      [
        ::Simple::Httpd::Rack::DynamicMount.build(mount_point, path),
        ::Simple::Httpd::Rack::StaticMount.build(mount_point, path)
      ].compact
    end

    private

    def normalize_and_verify_path!(path)
      path = path.gsub(/\/$/, "") # remove trailing "/"

      raise ArgumentError, "You probably don't want to mount your root directory, check mount_spec" if path == ""
      raise Errno::ENOENT, path unless Dir.exist?(path)

      path
    end

    def normalize_and_verify_mount_point!(mount_point)
      mount_point ||= "/"                           # fall back to "/"
      mount_point = File.join("/", mount_point)     # make sure we start at "/"

      canary_url = "http://0.0.0.0#{mount_point}"   # verify mount_point: can it be used to build a URL?
      URI.parse canary_url

      mount_point
    end
  end

  class ServiceMountSpec < ::Simple::Httpd::MountSpec
  end
end
