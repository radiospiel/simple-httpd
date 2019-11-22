class Simple::Httpd::Route
  H = ::Simple::Httpd::Helpers
  SELF = self

  attr_reader :verb, :path, :source_location

  def self.build(route)
    expect! route => [
      ::Simple::Httpd::Route,
      {
        verb: %w(GET POST PUT DELETE HEAD OPTIONS),
        path: String,
        source_location: [nil, Array, String]
      }
    ]

    return route if route.is_a?(self)

    ::Simple::Httpd::Route.new(*route.values_at(:verb, :path, :source_location))
  end

  private

  def initialize(verb, path, source_location)
    @verb = verb
    @path = path
    @source_location = source_location
  end

  public

  def to_s
    parts = [verb, path, source_location_str]
    parts.compact.join " "
  end

  def inspect
    "<#{SELF.name}: #{self}>"
  end

  def prefix(*prefixes)
    SELF.new(verb, File.join(*prefixes, path), source_location)
  end

  private

  def source_location_str
    case source_location
    when Array
      path, lineno = *source_location
      path = H.shorten_path(path)
      "#{path}:#{lineno}"
    when String, nil
      source_location
    else
      source_location.inspect
    end
  end
end

module Simple::Httpd::RouteDescriptions
  # returns a list of route desc entries.
  #
  # When building a simple-httpd application we also collect all routes defined
  # via get, put, etc., including their source location (which, for example,
  # might point to a service's method or to a controller source file).
  #
  # (see <tt>Simple::Httpd::Route</tt>).
  def route_descriptions
    @route_descriptions ||= []
  end

  # Adds a route description.
  #
  # The argument must either be a Route, or an argument acceptable to Route.build.
  #
  # (see <tt>Simple::Httpd::Route</tt>).
  def describe_route!(route)
    route_descriptions << ::Simple::Httpd::Route.build(route)
  end
end
