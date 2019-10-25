require "spec_helper"

describe Simple::Httpd do
  describe "VERSION" do
    it "defines a version string" do
      expect(Simple::Httpd::VERSION).to match(/^\d+\.\d+\.\d+/)
    end
  end

  describe "root routing" do
    it "resolves routes from root.rb" do
      http.get "/"
      expect_response "hello"
    end
  end

  describe "static files" do
    it "returns a static file" do
      http.get "/README.txt"
      expect_response "This is a README file\n"
    end

    it "does not return an unsecured static file" do
      http.get "/root.rb"
      expect_response 404
    end
  end
end
