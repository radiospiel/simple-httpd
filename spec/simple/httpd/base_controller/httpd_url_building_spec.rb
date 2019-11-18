require "spec_helper"

describe Simple::Httpd do
  describe "full_url" do
    it "builds a full_url" do
      http.get "/spec/full_url"
      expect_response("http://127.0.0.1:12345/foo?search=s&page=1")
    end
  end

  describe "url" do
    it "returns X-Processing headers on dynamic responses" do
      http.get "/spec/url"
      expect_response("foo?search=s&page=1")
    end
  end
end
