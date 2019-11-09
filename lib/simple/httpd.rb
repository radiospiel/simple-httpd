# rubocop:disable Style/TrivialAccessors

module Simple
end

class Simple::Httpd
end

require "simple/httpd/version"
require "simple/httpd/helpers"
require "simple/httpd/base_controller"
require "simple/httpd/rack"
require "simple/httpd/server"

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
  def self.listen!(*mount_specs, environment: "development", port:, logger: nil, &block)
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
    end

    Server.listen!(app, environment: environment, port: port, logger: logger)
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
      mount(mount_spec)
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
  def mount(mount_spec)
    raise ArgumentError, "Cannot mount onto an already built app" if built?

    @mount_specs << PathMountSpec.new(mount_spec)
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
      apps = mount_specs.inject([]) do |ary, mount_spec|
        ary << Rack::DynamicMount.build(mount_point, mount_spec.path)
        ary << Rack::StaticMount.build(mount_point, mount_spec.path)
      end.compact

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

  # functions to parse a PathMountSpec
  class PathMountSpec
    attr_reader :path, :mount_point

    def self.build(mount_spec)
      return mount_spec if mount_spec.is_a?(self)

      new(mount_spec)
    end

    private

    def initialize(str)
      @path, @mount_point = str.split(":", 2)

      normalize_and_verify_path!
      normalize_and_verify_mount_point!
    end

    def normalize_and_verify_path!
      @path = @path.gsub(/\/$/, "") # remove trailing "/"

      raise ArgumentError, "You probably don't want to mount your root directory, check mount_spec" if @path == ""
      raise Errno::ENOENT, path unless Dir.exist?(path)
    end

    def normalize_and_verify_mount_point!
      @mount_point ||= "/"                           # fall back to "/"
      @mount_point = File.join("/", @mount_point)     # make sure we start at "/"

      canary_url = "http://0.0.0.0#{@mount_point}"   # verify mount_point: can it be used to build a URL?
      URI.parse canary_url
    end
  end

  # functions to build a PathMountSpec
  class PathMountSpec
    attr_reader :path, :mount_point

    private

    def initialize(str)
      raise ArgumentError unless str.is_a?(String)

      @path, @mount_point = str.split(":", 2)

      normalize_and_verify_path!
      normalize_and_verify_mount_point!
    end

    def normalize_and_verify_path!
      @path = @path.gsub(/\/$/, "") # remove trailing "/"

      raise ArgumentError, "You probably don't want to mount your root directory, check mount_spec" if @path == ""
      raise Errno::ENOENT, path unless Dir.exist?(path)
    end

    def normalize_and_verify_mount_point!
      @mount_point ||= "/"                           # fall back to "/"
      @mount_point = File.join("/", @mount_point)     # make sure we start at "/"

      canary_url = "http://0.0.0.0#{@mount_point}"   # verify mount_point: can it be used to build a URL?
      URI.parse canary_url
    end
  end
end
