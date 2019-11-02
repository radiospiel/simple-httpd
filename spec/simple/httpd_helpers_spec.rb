require "spec_helper"

describe Simple::Httpd do
  describe "helpers" do
    it "loads helpers from the same directory tree" do
      http.get "/helpers/ex2"
      expect_response 'ex2_helper'
    end

    it "does not load helpers from other directory tree even on the same URL tree" do
      http.get "/helpers/ex1"
      expect_response status: 404
    end
  end
end
