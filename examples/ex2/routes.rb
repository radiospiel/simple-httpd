get "/debug" do
  debug params
end

[:get, :post, :put, :delete, :head].each do |verb|
  send verb, "/info/inspect" do
    content_type :text
    request.env.map { |key, value| "#{key}=#{value}\n" }.grep(/^[A-Z]/).sort.join
  end
end

get "/helpers/ex1" do
  ex1_helper
rescue NameError
  not_found! "ex1_helper cannot be run"
end

get "/helpers/ex2" do
  ex2_helper
rescue NameError
  not_found! "ex2_helper cannot be run"
end
