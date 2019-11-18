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
      require "neatjson"
    rescue LoadError
      :nop
    end

    def generate_json(result)
      JSON.respond_to?(:neat_generate) ? JSON.neat_generate(result) : JSON.pretty_generate(result)
    end
  end
end
