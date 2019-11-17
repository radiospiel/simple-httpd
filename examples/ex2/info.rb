[:get, :post, :put, :delete, :head].each do |verb|
  send verb, "/inspect" do
    content_type :text
    request.env.map { |key, value| "#{key}=#{value}\n" }.grep(/^[A-Z]/).sort.join
  end
end
