class Simple::Httpd::App::FileServer
  # A simple file server middleware
  def initialize(app, url_prefix:, root:)
    @app = app
    @url_prefix = File.join("/", url_prefix, "/")
    @file_server = Rack::File.new(root)
  end

  def call(env)
    request_path = env["PATH_INFO"]
    if request_path.start_with?(@url_prefix)
      file_path = request_path[@url_prefix.length..-1]
      env["PATH_INFO"] = file_path
      @file_server.call(env)
    else
      @app.call(env)
    end
  end
end
