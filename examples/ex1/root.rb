# This would be an example of sleeping for 1 sec with thin/eventmachine.
#
# aget "/" do
#   EM.add_timer(1) {
#     body { "hello sync" }
#   }
# end

get "/" do
  "root"
end

get "/hello" do
  "hello"
end

get "/exit" do
  exit 1
end

get "/sideloaded_service" do
  Ex1ServiceModule.hello_world
end
