# Note that all components in base_controller/*.rb are loaded automatically, from
# config/routes.rb, **after** this file is loaded. See the end of this file.

require "sinatra/base"

class Simple::Httpd::BaseController < Sinatra::Base
  set :logging, true

  # --- Sinatra::Reloader -----------------------------------------------------

  # Note that Sinatra::Reloader is less thorough than, say, shotgun or the
  # Rails development mode, but on the other hand it is much faster, and
  # probably useful 90% of the time.
  configure :development do
    # require "sinatra/reloader"
    # register Sinatra::Reloader
  end
end

require_relative "./route"

class Simple::Httpd::BaseController
  extend ::Simple::Httpd::RouteDescriptions
end

Dir.chdir __dir__ do
  Dir.glob("base_controller/*.rb").sort.each do |file|
    require_relative file
  end
end
