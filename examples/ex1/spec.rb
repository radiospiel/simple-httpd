get "/full_url" do
  full_url "foo", search: "s", page: 1
end

get "/url" do
  url "foo", search: "s", page: 1
end
