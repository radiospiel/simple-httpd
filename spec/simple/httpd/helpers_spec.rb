require "spec_helper"

describe "Simple::Httpd::Helpers" do
  H = Simple::Httpd::Helpers
  
  describe ".filtered_stacktrace" do
    def some_stacktrace(depth = 1)
      if depth == 0
        caller
      else
        some_stacktrace(depth-1)
      end
    end

    def filtered_stacktrace
      H.filtered_stacktrace(some_stacktrace)
    end

    it "removes .rvm lines" do
      actual = filtered_stacktrace

      expect(actual.grep(/lines removed/).count).to eq(1)
      expect(actual.grep(/helpers_spec/).count).to be > 1 
      expect(actual.grep(/some_stacktrace/).count).to eq(1)
    end

    it "shortens paths" do
      source_path = filtered_stacktrace.grep(/helpers_spec/).first
      expect(source_path).to start_with("./")
    end
  end
end
