require "spec_helper"

describe "RSpec::Httpd features" do
  VERBS_WO_BODY = [ :options, :head ]

  VERBS = [ :get, :post, :put, :delete ]

  VERBS.each do |verb|
    it "sends proper headers in #{verb} request" do
      http.send verb, "/info/inspect?qux"

      result_lines = http.content.split("\n")

      expect(result_lines).to include("QUERY_STRING=qux")
      expect(result_lines).to include("REQUEST_METHOD=#{verb.upcase}")
      expect(result_lines).to include("REQUEST_PATH=/info/inspect")
      expect(result_lines).to include("SERVER_NAME=127.0.0.1")
      expect(result_lines).to include("SERVER_PORT=12345")

      expect(http.response.headers["content-type"]).to match(/text\/plain/)
    end
  end

  VERBS_WO_BODY = [ :options, :head ]

  VERBS_WO_BODY.each do |verb|
    it "supports #{verb} methods" do
      http.send verb, "/info/inspect?qux"

      expect_response 200
    end
  end
end
