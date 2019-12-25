require "expectation"

# The Simple::Httpd::Mountpoint.build returns a Rack compatible app, which
# serves HTTP requests according to a set of dynamic ruby scripts and some
# existing static files.
class Simple::Httpd::Rack::DynamicMount
  H = ::Simple::Httpd::Helpers

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

    ::Simple::Httpd::Reloader.attach self, paths: service_files, reloading_instance: nil

    @rack_app = H.subclass ::Simple::Httpd::BaseController,
                           paths: helper_files + ["#{path}/routes.rb"],
                           description: "<controller:#{H.shorten_path(path)}>"

    @rack_app.route_descriptions.each do |route|
      describe_route! route.prefix(@mount_point)
    end
  end

  # RouteDescriptions are being built during build_url_map
  include ::Simple::Httpd::RouteDescriptions

  private

  def service_files
    service_files = Dir.glob("#{path}/services/**/*.rb").sort
    ::Simple::Httpd.logger.info "#{path}: loading #{service_files.count} service file(s)" if service_files.count > 0
    service_files
  end

  def helper_files
    helper_files = Dir.glob("#{path}/helpers/**/*.rb").sort
    ::Simple::Httpd.logger.info "#{path}: loading #{helper_files.count} helper file(s)" if helper_files.count > 0
    helper_files
  end
end
