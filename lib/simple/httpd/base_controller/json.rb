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

  def parsed_json_body
    @parsed_json_body ||= parse_json_body
  end

  private

  def parse_json_body
    unless request.content_type =~ /application\/json/
      raise "Cannot parse non-JSON request body w/content_type #{request.content_type.inspect}"
    end

    request.body.rewind
    JSON.parse(request.body.read)
  end
end
