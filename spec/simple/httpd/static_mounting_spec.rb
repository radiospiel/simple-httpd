require "spec_helper"

describe "static mounting" do
  it "returns a static file" do
    http.get "/README.txt"
    expect_response "This is a README file\n"
  end

  it "does not return a forbidden static file" do
    http.get "/root.rb"
    expect_response 404
  end
end
