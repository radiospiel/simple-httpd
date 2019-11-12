# rubocop:disable Style/TrivialAccessors

module Simple
end

class Simple::Httpd
end

require "simple/service"

require "simple/httpd/helpers"
require "simple/httpd/base_controller"
require "simple/httpd/version"
require "simple/httpd/mount_spec"
require "simple/httpd/server"

require "simple/httpd/service"

class Simple::Httpd
  SELF = self

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger ||= ::Logger.new(STDERR, level: ::Logger::INFO)
  end

  # Converts the passed in args into a Simple::Httpd application.
  #
  # The passed in arguments are used to create a Simple::Httpd object.
  # If the function receives a rack app (determined by the ability to
  # respond to call/3) it redirects to <tt>Server.listen!</tt> right
  # away - this way this method can be used as a helper method
  # to easily start a Rack server.
  def self.listen!(*mount_specs, environment: "development", host: nil, port:, logger: nil, &block)
    # If there is no argument but a block use the block as a rack server
    if block
      raise ArgumentError, "Can't deal w/block *and* mount_specs" unless mount_specs.empty?

      app = block
    elsif mount_specs.length == 1 && mount_specs.first.respond_to?(:call)
      # there is one argument, and that looks like a Rack app: return that.
      app = mount_specs.first
    else
      # Build a Httpd app, and listen
      app = build(*mount_specs)
      app.rack
    end

    Server.listen!(app, environment: environment, host: host, port: port, logger: logger)
  end

  # Converts the passed in arguments into a Simple::Httpd application.
  #
  # For a description of mounts see <tt>#add</tt>
  def self.build(*mount_specs)
    new(*mount_specs)
  end

  private

  # Builds a Simple::Httpd application.
  def initialize(*mount_specs)
    @mount_specs = []
    mount_specs.map do |mount_spec|
      mount(mount_spec, at: nil)
    end
  end

  public

  # Adds one or more mount_points
  #
  # Each entry in mounts can be either:
  #
  # - a mount_point <tt>[ mount_point, path ]</tt>, e.g. <tt>[ "path/to/root", "/"]</tt>
  # - a string denoting a mount_point, e.g. "path/to/root:/")
  # - a string denoting a "/" mount_point (e.g. "path", which is shorthand for "path:/")
  #
  def mount(mount_spec, at: nil)
    raise ArgumentError, "Cannot mount onto an already built app" if built?

    @mount_specs << MountSpec.build(mount_spec, at: at)
  end

  extend Forwardable
  delegate :call => :rack # rubocop:disable Style/HashSyntax

  def rack
    @rack ||= build_rack
  end

  private

  def build_rack
    uri_map = {}

    @mount_specs.group_by(&:mount_point).map do |mount_point, mount_specs|
      apps = mount_specs.map(&:build_rack_apps).flatten
      uri_map[mount_point] = Rack.merge(apps)
    end

    ::Rack::URLMap.new(uri_map)
  end

  def built?
    @rack != nil
  end

  public

  def listen!(environment:, port:, logger:)
    SELF.listen!(rack, environment: environment, port: port, logger: logger)
  end
end
