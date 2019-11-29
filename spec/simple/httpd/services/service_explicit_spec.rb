require "spec_helper"

describe "explicit mounting of service" do
  # mounting not at root level
  it "mounts the file" do
    http.get "/example_service/check"
    expect_response("ok: explicit_service")
  end

  it "properly extracts an argument from the path" do
    http.post "/example_service/echo/1?b=2", { one: "foo", two: "bar" }
    expect_response "one: [foo]/two: [bar]/a: [1]/b: [2]"
  end

  it "ignores extra body arguments and extra parameters" do
    http.post "/example_service/echo/1?b=2&c=3", { one: "foo", two: "bar", three: "baz" }
    expect_response "one: [foo]/two: [bar]/a: [1]/b: [2]"
  end

  it "complains on missing body arguments" do
    http.post "/example_service/echo/1?b=2&c=3", { two: "bar" }
    expect_response 422
  end

  it "properly extracts arguments and parameters" do
    http.put "/example_service/echo_context"
    expect_response /Simple::Service::Context/
  end
end
