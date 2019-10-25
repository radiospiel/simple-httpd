require "expectation"

# The Simple::Httpd::Mountpoint.build returns a Rack compatible app, which
# serves HTTP requests according to a set of dynamic ruby scripts and some
# existing static files.
module Simple::Httpd::Rack::DynamicMount
  Rack = ::Simple::Httpd::Rack

  extend self

  def build(mountpoint, path)
    expect! path => String

    # build a URLMap for all controllers
    url_map = build_url_map(mountpoint, path)
    return nil if url_map.empty?

    ::Rack::URLMap.new(url_map)
  end

  private

  def build_url_map(base_mountpoint, path)
    Dir.glob("#{path}/**/*.rb").sort.each_with_object({}) do |absolute_path, url_map|
      relative_path = absolute_path[(path.length)..-1]

      relative_mountpoint = relative_path == "/root.rb" ? "/" : relative_path.gsub(/\.rb$/, "")
      controller_class = load_controller absolute_path

      absolute_mountpoint = File.join(base_mountpoint, relative_mountpoint)
      ::Simple::Httpd.logger.info "Mounting #{absolute_path} at #{absolute_mountpoint}"

      url_map.update relative_mountpoint => controller_class
    end
  end

  # wraps the source file in path into a Simple::Httpd::BaseController.
  def load_controller(path)
    controller_class = Class.new Simple::Httpd::BaseController
    controller_class.instance_eval File.read(path), path, 1
    controller_class
  end
end
