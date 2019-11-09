module Simple::Httpd::Helpers
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
  def instance_eval_paths(obj, *paths)
    paths.each do |path|
      # STDERR.puts "Loading #{path}"
      obj.instance_eval File.read(path), path, 1
    end
    obj
  end

  # subclass a klass with an optional description
  def subclass(klass, description: nil)
    subclass = Class.new(klass)
    subclass.define_method(:inspect) { description } if description
    subclass
  end
end
