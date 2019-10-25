require "spec_helper"

describe Simple::Httpd do
  describe "CORS headers" do
    it "returns CORS headers on dynamic responses" do
      http.get "/"
      expect(http.response.headers.keys).to include("access-control-allow-origin")
    end

    it "returns CORS headers" do
      http.get "/README.txt"
      expect(http.response.headers.keys).not_to include("access-control-allow-origin")
    end
  end
end
