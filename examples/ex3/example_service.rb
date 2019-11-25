get "/check" do
  "ok: explicit_service"
end

mount_service ExplicitService do |service|
  # def echo(one, two, a:, b:)
  post "/echo/:a" => :explicit_echo

  put "/echo_context" do
    # def echo_context
    ::Simple::Service.invoke(service, :echo_context, parsed_body, params, context: context)
  end
end
