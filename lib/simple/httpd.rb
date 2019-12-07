# rubocop:disable Style/TrivialAccessors

module Simple
end

class Simple::Httpd
end

require "simple/service"
require "simple/httpd/helpers"
require "simple/httpd/reloader"
require "simple/httpd/base_controller"
require "simple/httpd/version"
require "simple/httpd/mount"
require "simple/httpd/server"
require "simple/httpd/service_integration"

class Simple::Httpd
  SELF = self

  class << self
    attr_accessor :env
  end

  self.env = "development"

  # returns a logger for Simple::Httpd.
  #
  # Initially we default to <tt>::Simple::CLI.logger</tt>. This gives colored
  # logging during loading and mounting. Note that Simple::Httpd::Server builds
  # its own logger instance to to pass that along to the web server.
  def self.logger
    @logger ||= ::Simple::CLI.logger
  end

  def self.custom_logger?
    @logger && @logger != ::Simple::CLI.logger
  end

  def self.logger=(logger)
    @logger = logger
  end

  # Converts the passed in args into a Simple::Httpd application.
  #
  # The passed in arguments are used to create a Simple::Httpd object.
  # If the function receives a rack app (determined by the ability to
  # respond to call/3) it redirects to <tt>Server.listen!</tt> right
  # away - this way this method can be used as a helper method
  # to easily start a Rack server.
  def self.listen!(*mounts, environment: "development", host: nil, port:, &block)
    # If there is no argument but a block use the block as a rack server
    if block
      raise ArgumentError, "Can't deal w/block *and* mounts" unless mounts.empty?

      app = block
    elsif mounts.length == 1 && mounts.first.respond_to?(:call)
      # there is one argument, and that looks like a Rack app: return that.
      app = mounts.first
    else
      # Build a Httpd app, and listen
      app = build(*mounts)
      app.rack
    end

    Server.listen!(app, environment: environment, host: host, port: port)
  end

  # Converts the passed in arguments into a Simple::Httpd application.
  #
  # For a description of mounts see <tt>#add</tt>
  def self.build(*mounts)
    new(*mounts)
  end

  private

  # Builds a Simple::Httpd application.
  def initialize(*mounts)
    @mounts = []
    mounts.map do |mount|
      mount(mount, at: nil)
    end
  end

  public

  def route_descriptions
    @mounts.inject([]) do |ary, mount|
      ary.concat mount.route_descriptions
    end
  end

  # Adds one or more mount_points
  #
  # Each entry in mounts can be either:
  #
  # - a mount_point <tt>[ mount_point, path ]</tt>, e.g. <tt>[ "path/to/root", "/"]</tt>
  # - a string denoting a mount_point, e.g. "path/to/root:/")
  # - a string denoting a "/" mount_point (e.g. "path", which is shorthand for "path:/")
  #
  def mount(mount, at: nil)
    raise ArgumentError, "Cannot mount onto an already built app" if built?

    @mounts << Mount.build(mount, at: at)
  end

  extend Forwardable
  delegate :call => :rack # rubocop:disable Style/HashSyntax

  def rack
    @rack ||= build_rack
  end

  private

  def build_rack
    uri_map = {}

    @mounts.group_by(&:mount_point).map do |mount_point, mounts|
      apps = mounts.map(&:build_rack_apps).flatten
      uri_map[mount_point] = Rack.merge(apps)
    end

    ::Rack::URLMap.new(uri_map)
  end

  def built?
    @rack != nil
  end
end
