module Simple::Httpd::Reloader
  def self.attach(target, paths:, reloading_instance: target)
    target.extend self
    target.load!(paths: paths, reloading_instance: reloading_instance)
    target
  end

  H = ::Simple::Httpd::Helpers

  attr_accessor :reloading_paths

  def load!(paths:, reloading_instance:)
    paths = Array(paths)
    paths = nil if paths.empty?

    @__reload_paths__ = paths
    @__reloading_instance__ = reloading_instance

    reload_all_changed_files
  end

  def reload!
    # if this is a class, and its superclass is also reloadable,
    # reload the superclass first.
    if respond_to?(:superclass) && superclass&.respond_to?(:reload!)
      superclass.reload!
    end

    reload_all_changed_files
  end

  private

  def reload_all_changed_files
    return unless @__reload_paths__

    @__reload_paths__.each do |path|
      reload_file_if_necessary(path)
    end
  end

  def reload_file_if_necessary(path)
    @__source_mtimes_by_path__ ||= {}

    mtime = File.mtime(path)
    return if @__source_mtimes_by_path__[path] == mtime

    Simple::Httpd.logger.debug do
      verb = @__source_mtimes_by_path__.key?(path) ? "reloading" : "loading"
      "#{verb} #{H.shorten_path path}"
    end

    silence_warnings do
      if @__reloading_instance__
        @__reloading_instance__.instance_eval File.read(path), path, 1
      else
        load path
      end
    end

    @__source_mtimes_by_path__[path] = mtime
  end

  def silence_warnings(&block)
    warn_level = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = warn_level
  end
end
