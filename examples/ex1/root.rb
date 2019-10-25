get "/" do
  "root"
end

get "/hello" do
  "hello"
end

get "/exit" do
  exit 1
end
