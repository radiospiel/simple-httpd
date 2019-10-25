require "spec_helper"

describe Simple::Httpd do
  describe "RSpec::Httpd features" do
    it "sends proper headers" do
      http.get "/info/inspect?qux"

      result_lines = http.result.split("\n")

      expect(result_lines).to include("QUERY_STRING=qux")
      expect(result_lines).to include("REQUEST_METHOD=GET")
      expect(result_lines).to include("REQUEST_PATH=/info/inspect")
      expect(result_lines).to include("SERVER_NAME=127.0.0.1")
      expect(result_lines).to include("SERVER_PORT=12345")

      expect(http.response.headers["content-type"]).to match(/text\/plain/)
    end
  end
end
