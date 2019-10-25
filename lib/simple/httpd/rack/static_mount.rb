# A simple file server middleware
class Simple::Httpd::Rack::StaticMount
  Rack = ::Simple::Httpd::Rack

  def self.build(path)
    return nil unless static_files?(path)

    new(path)
  end

  def self.static_files?(path)
    pattern = "#{path}/**/*{" + EXTENSIONS.join(",") + "}"
    Dir.glob(pattern) { return true }
    false
  end

  EXTENSIONS = %w(
    .txt .md
    .js .css
    .png .jpeg .jpg
  )

  attr_reader :mount_point, :path

  def initialize(path)
    @path = path
  end

  def call(env)
    request_path = env["PATH_INFO"]
    if serve_file?(request_path)
      file_path = request_path[1..-1]
      env["PATH_INFO"] = file_path
      file_server.call(env)
    else
      Rack.error 404, "No such file"
    end
  end

  def file_server
    @file_server ||= ::Rack::File.new(path)
  end

  def serve_file?(request_path)
    EXTENSIONS.include?(File.extname(request_path))
  end
end
