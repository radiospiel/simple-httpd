require "expectation"

# The Simple::Httpd::Mountpoint.build returns a Rack compatible app, which
# serves HTTP requests according to a set of dynamic ruby scripts and some
# existing static files.
class Simple::Httpd::Rack::DynamicMount
  H = ::Simple::Httpd::Helpers
  Rack = ::Simple::Httpd::Rack

  def self.build(mount_point, path)
    expect! path => String

    url_map = new(mount_point, path).url_map

    ::Rack::URLMap.new(url_map)
  end

  attr_reader :path
  attr_reader :mount_point

  def initialize(mount_point, path)
    @mount_point = mount_point
    @path = path
  end

  def url_map
    load_services!

    # determine source_paths and controller_paths
    source_paths = Dir.glob("#{path}/**/*.rb")

    helper_paths, controller_paths = source_paths.partition { |str| /_helper(s?)\.rb$/ =~ str }

    # build root controller
    root = build_root_controller(helper_paths)
    build_url_map(controller_paths, root: root)
  end

  private

  def service_path
    path.gsub(/\/\z/, "") + ".services"
  end

  def logger
    ::Simple::Httpd.logger
  end

  def load_services!
    logger.info "Loading service files from #{service_path}"
    Dir.glob("#{service_path}/**/*.rb").sort.each do |path|
      logger.debug "Loading service file #{path.inspect}"
      load path
    end
  end

  # rubocop:disable Metrics/AbcSize
  def build_url_map(controller_paths, root:)
    controller_paths.sort.each_with_object({}) do |absolute_path, url_map|
      relative_path = absolute_path[(path.length)..-1]

      relative_mount_point = relative_path == "/root.rb" ? "/" : relative_path.gsub(/\.rb$/, "")
      controller_class = load_controller absolute_path, root: root

      logger.info do
        absolute_mount_point = File.join(mount_point, relative_mount_point)
        routes_count = controller_class.routes.reject { |verb, _| verb == "HEAD" }.values.sum(&:count)

        "#{absolute_mount_point}: mounting #{routes_count} route(s) from #{H.shorten_path absolute_path}"
      end

      url_map.update relative_mount_point => controller_class
    end
  end

  # wraps all helpers into a Simple::Httpd::BaseController subclass
  def build_root_controller(helper_paths)
    klass = H.subclass ::Simple::Httpd::BaseController,
                       description: "root controller at #{path} w/#{helper_paths.count} helpers"

    H.instance_eval_paths klass, *helper_paths.sort
  end

  # wraps the source file in path into a root_controller
  def load_controller(path, root:)
    klass = H.subclass root, description: "controller at #{path}"
    H.instance_eval_paths klass, path
  end
end
