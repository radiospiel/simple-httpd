class Simple::Httpd::BaseController
  helpers do
    def origin
      request["Origin"] ||
        "#{request.scheme}://#{request.host_with_port}"
    end
  end
end
