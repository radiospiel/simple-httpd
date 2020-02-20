# A simple file server middleware
class Simple::Httpd::Rack::StaticMount
  H = ::Simple::Httpd::Helpers
  Rack = ::Simple::Httpd::Rack

  EXTENSIONS = %w(.txt .md .js .css .png .jpeg .jpg .html)
  GLOB_PATTERN = "**/*.{#{EXTENSIONS.map { |s| s[1..-1] }.join(",")}}"

  def self.build(mount_point, path)
    static_files = Dir.chdir(path) { Dir.glob(GLOB_PATTERN) }

    return nil if static_files.empty?

    ::Simple::Httpd.logger.info do
      "#{mount_point}: serving #{static_files.count} static file(s)"
    end

    if ::Simple::Httpd.logger.debug?
      static_files.sort.each do |file|
        ::Simple::Httpd.logger.debug "#{mount_point}/#{file}"
      end
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
    file_path = lookup_static_file(env["PATH_INFO"])
    if file_path
      env["PATH_INFO"] = file_path
      @file_server.call(env)
    else
      Rack.error 404, "No such file"
    end
  end

  private

  def lookup_static_file(path_info)
    relative_path = path_info[1..-1]
    return relative_path if @static_files.include?(relative_path)

    # determine potential index paths
    index_paths = %w(index.html README.md)

    if relative_path != ""
      index_paths = index_paths.map do |index_file|
        File.join(relative_path, index_file)
      end
    end

    (index_paths & @static_files.to_a).first
  end
end
