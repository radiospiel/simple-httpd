require "spec_helper"

describe Simple::Httpd do
  describe "X-Processing headers" do
    it "returns X-Processing headers on dynamic responses" do
      http.get "/"
      expect(http.response.headers.keys).to include("x-processing")
    end

    it "returns X-Processing headers on static responses" do
      http.get "/README.txt"
      expect(http.response.headers.keys).not_to include("x-processing")
    end
  end
end
