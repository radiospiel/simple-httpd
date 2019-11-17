require "spec_helper"

describe Simple::Httpd do
  describe "CORS headers" do
    it "returns CORS headers on dynamic responses" do
      http.get "/"
      expect(http.response.headers.keys).to include("access-control-allow-origin")
    end

    it "sends proper headers in all request methods" do
      verbs = [ :get, :post, :put, :delete, :options, :head ]
      verbs.each do |verb|
      http.send verb, "/info/inspect?qux"

      expect_response 200
      expect(http.response.headers.keys).to include("access-control-allow-origin")
end
    end
  end
end
