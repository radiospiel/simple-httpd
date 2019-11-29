get "/check" do
  "ok: explicit_service"
end

mount_service ExplicitService do |service|
  # def echo(one, two, a:, b:)
  post "/echo/:a" => :explicit_echo

  put "/echo_context" do
    ::Simple::Service.with_context(context) do
      ::Simple::Service.invoke(service, :echo_context)
    end
  end
end
