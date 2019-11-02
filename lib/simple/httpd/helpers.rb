module Simple::Httpd::Helpers
  extend self

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
