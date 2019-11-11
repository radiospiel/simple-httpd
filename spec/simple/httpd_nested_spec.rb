require "spec_helper"

describe Simple::Httpd do
  describe "deep mounting" do
    # mounting not at root level
    it "gets deep route from root.rb file" do
      http.get "/api/v2"
      expect(http.content).to eq("version" => "v2")
      expect(http.response.headers["content-type"]).to match(/application\/json/)
    end

    it "gets deep route from static file" do
      http.get "/api/v2/api.js"
      expect_response /API example file/
      expect(http.response.headers["content-type"]).to match(/application\/javascript/)
    end

    it "gets deep route from non-root.rb file" do
      http.get "/api/v2/jobs/info"
      expect_response "info"
      expect(http.response.headers["content-type"]).to match(/text\/plain/)
    end

    it "gets deep route with params from non-root.rb file" do
      http.get "/api/v2/jobs/12/events"
      expect(http.response.headers["content-type"]).to match(/application\/json/)
      expect(http.content).to eq([{ "job_id" => "12", "id" => "event1" }, { "job_id" => "12", "id" => "event2" }])
    end
  end
end
