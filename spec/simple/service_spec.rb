require "spec_helper"

describe Simple::Service do
  describe "service file" do
    # mounting not at root level
    it "returns value from mapped function" do
      http.post "/service/example/test?a=1&b=2"
      expect_response("hello from ExampleService#test")
    end

    it "properly extracts arguments and parameters" do
      http.post "/service/example/echo?a=1&b=2", { one: "foo", two: "bar" }
      expect_response "one: [foo]/two: [bar]/a: [1]/b: [2]"
    end

    it "ignores extra body arguments and extra parameters" do
      http.post "/service/example/echo?a=1&b=2&c=3", { one: "foo", two: "bar", three: "baz" }
      expect_response "one: [foo]/two: [bar]/a: [1]/b: [2]"
    end

    it "complains on missing body arguments" do
      http.post "/service/example/echo?a=1&b=2&c=3", { two: "bar" }
      expect_response 422
    end

    it "ignores missing parameters arguments" do
      http.post "/service/example/echo?b=2", { one: "foo", two: "bar" }
      expect_response "one: [foo]/two: [bar]/a: []/b: [2]"
    end

    it "properly extracts arguments and parameters" do
      http.post "/service/example/echo_context"
      expect_response /Simple::Service::Context/
    end
  end
end
