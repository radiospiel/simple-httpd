module Simple::Httpd::Helpers
  module SinatraRequestHeaders
    def headers
      env.each_with_object({}) do |(key, value), hsh|
        next unless key =~ /\AHTTP_(.*)/

        key = $1.split("_").collect(&:capitalize).join("-")
        hsh[key] = value
      end
    end
  end
  ::Sinatra::Request.include(SinatraRequestHeaders)

  extend self

  private

  def pwd
    @pwd ||= File.join(Dir.getwd, "/")
  end

  def home
    @home ||= File.join(Dir.home, "/")
  end

  public

  def shorten_path(path)
    path = File.absolute_path(path)

    shorten_absolute_path(path)
  end

  def shorten_absolute_path(path)
    if path.start_with?(pwd)
      path = path[pwd.length..-1]
      path = File.join("./", path) if path =~ /\//
    end

    if path.start_with?(home)
      path = File.join("~/", path[home.length..-1])
    end

    path
  end

  def underscore(str)
    parts = str.split("::")
    parts = parts.map do |part|
      part.gsub(/[A-Z]+/) { |ch| "_#{ch.downcase}" }.gsub(/^_/, "")
    end
    parts.join("/")
  end

  # instance_eval zero or more paths in the context of obj
  def instance_eval_paths(obj, paths:)
    return obj unless paths

    Array(paths).each do |path|
      # STDERR.puts "Loading #{path}"
      obj.instance_eval File.read(path), path, 1
    end
    obj
  end

  # subclass a klass with an optional description
  def subclass(klass, paths: nil, description: nil)
    raise "Missing description" unless description

    subclass = Class.new(klass)
    subclass.define_singleton_method(:description) { description }
    subclass.define_method(:inspect) { description } if description

    ::Simple::Httpd::Reloader.attach(subclass, paths: Array(paths))

    subclass
  end

  def filter_stacktrace_entry?(line)
    return true if line =~ /\.rvm\b/

    false
  end

  # Receives a stacktrace (like, for example, from Kernel#callers or
  # from Exception#backtrace), and removes all lines that point to
  # ".rvm". It also removes the working directory from the file paths.
  #
  # returns the cleaned array
  def filtered_stacktrace(stacktrace, count: 20)
    lines = []

    stacktrace[0..count].inject(false) do |filtered_last_line, line|
      if filter_stacktrace_entry?(line)
        lines << "... (lines removed) ..." unless filtered_last_line
        true
      else
        lines << shorten_path(line)
        false
      end
    end

    lines
  end
end
