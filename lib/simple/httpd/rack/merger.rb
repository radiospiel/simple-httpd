# A simple file server middleware
class Simple::Httpd::Rack::Merger
  Rack = Simple::Httpd::Rack

  # returns an app that merges other apps
  def self.build(apps)
    return apps.first if apps.length == 1

    new(apps)
  end

  private

  def initialize(apps)
    @apps = apps
  end

  public

  def call(env)
    @apps.each do |app|
      status, body, headers = app.call(env)
      return [status, body, headers] unless status == 404
    end

    Rack.error 404, "No such action"
  end
end
