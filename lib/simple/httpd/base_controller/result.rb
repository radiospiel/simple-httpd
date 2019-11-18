class ::Simple::Httpd::BaseController
  private

  # encodes the result, according to its payload.
  #
  # This function is used by the service integration code, but
  # is potentially useful outside.
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
