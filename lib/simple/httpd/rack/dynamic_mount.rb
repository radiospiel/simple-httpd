require "expectation"

# The Simple::Httpd::Mountpoint.build returns a Rack compatible app, which
# serves HTTP requests according to a set of dynamic ruby scripts and some
# existing static files.
class Simple::Httpd::Rack::DynamicMount
  H = ::Simple::Httpd::Helpers
  Rack = ::Simple::Httpd::Rack

  extend Forwardable

  def self.build(mount_point, path)
    expect! path => String
    new(mount_point, path)
  end

  def call(env)
    reload! if ::Simple::Httpd.env == "development"

    @rack_app.call(env)
  end

  attr_reader :path
  attr_reader :mount_point

  def initialize(mount_point, path)
    @mount_point = mount_point
    @path = path.gsub(/\/\z/, "") # remove trailing "/"

    setup_paths!
    ::Simple::Httpd::Reloader.attach self, paths: service_files, reloading_instance: nil

    @root_controller = build_root_controller # also loads helpers
    @url_map = build_url_map

    @rack_app = ::Rack::URLMap.new(@url_map)
  end

  # RouteDescriptions are being built during build_url_map
  include ::Simple::Httpd::RouteDescriptions

  private

  def logger
    ::Simple::Httpd.logger
  end

  def setup_paths!
    @source_paths = Dir.glob("#{path}/**/*.rb")
    @helper_paths, @controller_paths = @source_paths.partition { |str| /_helper(s?)\.rb$/ =~ str }

    logger.info "#{path}: found #{@source_paths.count} sources, #{@helper_paths.count} helpers"
  end

  def service_files
    @service_files ||= _service_files
  end

  def _service_files
    return [] if path == "." # i.e. mounting current directory

    service_path = "#{path}.services"
    service_files = Dir.glob("#{service_path}/**/*.rb").sort
    logger.info "#{service_path}: loading #{service_files.count} service file(s)"
    service_files
  end

  # wraps all helpers into a Simple::Httpd::BaseController subclass
  def build_root_controller
    H.subclass ::Simple::Httpd::BaseController,
               paths: @helper_paths.sort,
               description: "root controller at #{path} w/#{@helper_paths.count} helpers"
  end

  def build_url_map
    @controller_paths.sort.each_with_object({}) do |absolute_path, hsh|
      relative_path = absolute_path[(path.length)..-1]

      relative_mount_point = relative_path == "/root.rb" ? "/" : relative_path.gsub(/\.rb$/, "")
      controller_class = H.subclass @root_controller, description: "controller at #{absolute_path}", paths: absolute_path

      controller_class.route_descriptions.each do |route|
        route = route.prefix(@mount_point, relative_mount_point)
        describe_route! route
      end

      hsh.update relative_mount_point => controller_class
    end
  end
end
