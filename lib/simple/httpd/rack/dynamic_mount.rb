require "expectation"

# The Simple::Httpd::Mountpoint.build returns a Rack compatible app, which
# serves HTTP requests according to a set of dynamic ruby scripts and some
# existing static files.
class Simple::Httpd::Rack::DynamicMount
  H = ::Simple::Httpd::Helpers
  Rack = ::Simple::Httpd::Rack

  def self.build(mountpoint, path)
    expect! path => String

    url_map = new(mountpoint, path).build_url_map

    ::Rack::URLMap.new(url_map)
  end

  attr_reader :path
  attr_reader :mountpoint

  def initialize(mountpoint, path)
    @mountpoint = mountpoint
    @path = path

    # determine source_paths and controller_paths
    source_paths = Dir.glob("#{path}/**/*.rb")
    helper_paths, @controller_paths = source_paths.partition { |str| /_helpers\.rb$/ =~ str }

    # build root_controller
    @root_controller = build_root_controller(helper_paths)
  end

  def build_url_map
    @controller_paths.sort.each_with_object({}) do |absolute_path, url_map|
      relative_path = absolute_path[(path.length)..-1]

      relative_mountpoint = relative_path == "/root.rb" ? "/" : relative_path.gsub(/\.rb$/, "")
      controller_class = load_controller absolute_path

      absolute_mountpoint = File.join(mountpoint, relative_mountpoint)
      ::Simple::Httpd.logger.info "Mounting #{absolute_path} at #{absolute_mountpoint}"

      url_map.update relative_mountpoint => controller_class
    end
  end

  # wraps all helpers into a Simple::Httpd::BaseController subclass
  def build_root_controller(helper_paths)
    klass = H.subclass ::Simple::Httpd::BaseController,
                       description: "root controller at #{path} w/#{helper_paths.count} helpers"

    H.instance_eval_paths klass, *helper_paths.sort
  end

  # wraps the source file in path into a root_controller
  def load_controller(path)
    klass = H.subclass @root_controller, description: "controller at #{path}"
    H.instance_eval_paths klass, path
  end
end
