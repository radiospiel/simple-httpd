class Simple::Httpd::BaseController
  def json(result)
    content_type :json
    generate_json(result)
  end

  private

  def generate_json(result)
    JSON.generate(result)
  end

  configure :development, :test do
    begin
      @@neatjson = true
      require "neatjson"
    rescue LoadError
      @@neatjson = false
    end

    def generate_json(result)
      if @@neatjson
        JSON.neat_generate(result)
      else
        JSON.pretty_generate(result)
      end
    end
  end

  public

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
