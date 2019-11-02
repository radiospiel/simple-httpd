# A simple file server middleware
class Simple::Httpd::Rack::StaticMount
  Rack = ::Simple::Httpd::Rack

  EXTENSIONS = %w(.txt .md .js .css .png .jpeg .jpg)

  def self.build(mountpoint, path)
    static_files = static_files(path)
    return nil if static_files.empty?

    ::Simple::Httpd.logger.info "Serving #{static_files.count} static file(s) at #{mountpoint}"
    new(path, static_files)
  end

  def self.static_files(path)
    Dir.chdir(path) do
      pattern = "**/*{" + EXTENSIONS.join(",") + "}"
      Dir.glob(pattern)
    end
  end

  attr_reader :mountpoint, :path

  def initialize(path, static_files)
    @path = path
    @static_files = Set.new(static_files)
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
    @static_files.include?(request_path[1..-1])
  end
end
