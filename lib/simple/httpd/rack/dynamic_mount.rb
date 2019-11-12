require "expectation"

# The Simple::Httpd::Mountpoint.build returns a Rack compatible app, which
# serves HTTP requests according to a set of dynamic ruby scripts and some
# existing static files.
class Simple::Httpd::Rack::DynamicMount
  H = ::Simple::Httpd::Helpers
  Rack = ::Simple::Httpd::Rack

  def self.build(mount_point, path)
    expect! path => String

    url_map = new(mount_point, path).build_url_map

    ::Rack::URLMap.new(url_map)
  end

  attr_reader :path
  attr_reader :mount_point

  def initialize(mount_point, path)
    @mount_point = mount_point
    @path = path

    # determine source_paths and controller_paths
    source_paths = Dir.glob("#{path}/**/*.rb")
    helper_paths, @controller_paths = source_paths.partition { |str| /_helpers\.rb$/ =~ str }

    # build root_controller
    @root_controller = build_root_controller(helper_paths)
  end

  # rubocop:disable Metrics/AbcSize
  def build_url_map
    @controller_paths.sort.each_with_object({}) do |absolute_path, url_map|
      relative_path = absolute_path[(path.length)..-1]

      relative_mount_point = relative_path == "/root.rb" ? "/" : relative_path.gsub(/\.rb$/, "")
      controller_class = load_controller absolute_path

      ::Simple::Httpd.logger.info do
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
    klass
  end

  # wraps the source file in path into a root_controller
  def load_controller(path)
    klass = H.subclass @root_controller, description: "controller at #{path}"
    H.instance_eval_paths klass, path
  end
end
