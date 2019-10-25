get "/inspect" do
  content_type :text
  request.env.map { |key, value| "#{key}=#{value}\n" }.grep(/^[A-Z]/).sort.join
end
