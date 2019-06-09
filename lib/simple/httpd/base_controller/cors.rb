class Simple::Httpd::BaseController
  CORS_HEADERS = {
    "access-control-allow-credentials" => "true",
    "access-control-allow-headers" => "Origin,X-Requested-With,Content-Type,Accept,Session-Id",
    "access-control-allow-methods" => "*",
    "access-control-allow-origin" => "*",
    # "access-control-expose-headers" => "X-Total-Entries,X-Total-Pages,X-Page,X-Per-Page",
    # "access-control-max-age" => "-1",
    "access-control-max-age" => "600",
    "access-control-request-headers" => "Content-Type",
    "access-control-request-method" => "GET,POST,PATCH,PUT,DELETE,OPTIONS"
  }

  options "*" do
    200
  end

  after do
    headers CORS_HEADERS
  end
end
