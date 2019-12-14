# Note that all components in base_controller/*.rb are loaded automatically, from
# config/routes.rb, **after** this file is loaded. See the end of this file.

require "sinatra/base"
::Sinatra::Request.include(::Simple::Httpd::Helpers::RequestHeader)

class Simple::Httpd::BaseController < Sinatra::Base
  set :logging, true

  extend Simple::Httpd::Reloader

  def dispatch!
    self.class.reload! if ::Simple::Httpd.env == "development"

    super
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
