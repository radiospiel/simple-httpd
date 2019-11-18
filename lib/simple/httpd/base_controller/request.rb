class Simple::Httpd::BaseController
  def parsed_body
    return @parsed_body if defined? @parsed_body

    @parsed_body = parse_body
  rescue RuntimeError => e
    raise ArgumentError, e.to_s
  end

  private

  def parse_body
    case request.media_type
    when "application/json"
      request.body.rewind
      body = request.body.read
      body == "" ? {} : JSON.parse(body)
    else
      # parses form data
      request.POST
    end
  end
end
