module Simple::Httpd::Rack
end

require_relative "rack/static_mount"
require_relative "rack/dynamic_mount"
require_relative "rack/merger"

module Simple::Httpd::Rack
  def self.static_mount(mountpoint, path)
    StaticMount.build(mountpoint, path)
  end

  def self.dynamic_mount(mountpoint, path)
    DynamicMount.build(mountpoint, path)
  end

  def self.merge(apps)
    Merger.build(apps)
  end

  def self.error(status, message = nil)
    message ||= "Error #{status}"
    [status, {}, [message]]
  end
end
