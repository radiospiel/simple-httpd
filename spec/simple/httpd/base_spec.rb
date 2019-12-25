require "spec_helper"

describe Simple::Httpd do
  describe "VERSION" do
    it "defines a version string" do
      expect(Simple::Httpd::VERSION).to match(/^\d+\.\d+\.\d+/)
    end
  end

  describe "root routing" do
    it "resolves routes from routes.rb" do
      http.get "/"
      expect_response "root"
    end
  end
end
