require "spec_helper"

describe "sideloading" do
  # mounting not at root level
  it "sideloads code" do
    http.get "/sideloaded_service"
    expect_response("hello_world")
  end
end
