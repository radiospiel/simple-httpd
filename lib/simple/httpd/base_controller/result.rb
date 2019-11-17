class ::Simple::Httpd::BaseController
  private

  def encode_result(result)
    case result
    when Array, Hash
      json(result)
    when String
      content_type :text
      result
    else
      result
    end
  end
end
