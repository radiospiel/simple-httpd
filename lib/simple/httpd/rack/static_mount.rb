# A simple file server middleware
class Simple::Httpd::Rack::StaticMount
  H = ::Simple::Httpd::Helpers
  Rack = ::Simple::Httpd::Rack

  EXTENSIONS = %w(.txt .md .js .css .png .jpeg .jpg)
  GLOB_PATTERN = "**/*.{#{EXTENSIONS.map { |s| s[1..-1] }.join(",")}}"

  def self.build(mount_point, path)
    static_files = Dir.chdir(path) { Dir.glob(GLOB_PATTERN) }

    return nil if static_files.empty?

    ::Simple::Httpd.logger.info do
      "#{mount_point}: serving #{static_files.count} static file(s)"
    end

    new(mount_point, path, static_files)
  end

  attr_reader :mount_point, :path

  private

  def initialize(mount_point, path, static_files)
    @mount_point = mount_point
    @path = path
    @static_files = Set.new(static_files)
    @file_server = ::Rack::File.new(path)

    describe_route! verb: "GET",
                    path: File.join(mount_point, GLOB_PATTERN),
                    source_location: File.join(H.shorten_path(path), GLOB_PATTERN)
  end

  include ::Simple::Httpd::RouteDescriptions

  public

  def call(env)
    request_path = env["PATH_INFO"]
    if serve_file?(request_path)
      file_path = request_path[1..-1]
      env["PATH_INFO"] = file_path
      @file_server.call(env)
    else
      Rack.error 404, "No such file"
    end
  end

  private

  def serve_file?(request_path)
    @static_files.include?(request_path[1..-1])
  end
end
