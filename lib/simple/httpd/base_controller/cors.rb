class Simple::Httpd::BaseController
  # see https://fetch.spec.whatwg.org/#http-responses
  # see https://stackoverflow.com/questions/24264574/cors-headers-present-only-on-preflight-or-every-request

  options "*" do
    # The Access-Control max age setting is cached for up to 1 day. This value
    # is capped at different values depending on the browser.
    headers "Access-Control-Max-Age" => "86400"
    headers "Access-Control-Allow-Methods" => "*"
    headers "Access-Control-Allow-Headers" => "Origin,X-Requested-With,Content-Type,Accept,Session-Id"
    headers "Access-Control-Expose-Headers" => "X-Total-Entries,X-Total-Pages,X-Page,X-Per-Page"

    200
  end

  after do
    # This set of CORS headers must be set on each request.
    headers "Access-Control-Allow-Credentials" => "true",
            "Access-Control-Allow-Origin" => origin,
            "Vary" => "Accept-Encoding, Origin"
  end
end
