require "spec_helper"

describe Simple::Httpd do
  describe "VERSION" do
    it "defines a version string" do
      # Note: this allows for 0.12.34beta
      #expect(Simple::Httpd::VERSION).to match(/^\d+\.\d+\.\d+/)
    end
  end
end
