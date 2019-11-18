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
