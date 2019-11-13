require "spec_helper"

describe Simple::Httpd do
  describe "debug feature" do
    it "returns CORS headers on dynamic responses" do
      http.get "/debug?foo"
      expect_response '{"foo"=>nil}' + "\n"
      expect(http.response.headers["content-type"]).to match(/text\/plain/)
    end
  end
end
