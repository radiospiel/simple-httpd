get "/check" do
  "ok: explicit_service"
end

mount_service ExplicitService do |service|
  # def echo(one, two, a:, b:)
  post "/echo/:a" => :explicit_echo

  put "/echo_context" do
    service.invoke :echo_context
  end
end
