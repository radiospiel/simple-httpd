class Simple::Httpd::BaseController
  helpers do
    def debug(data)
      content_type "text/plain"
      halt data.pretty_inspect
    end
  end
end
