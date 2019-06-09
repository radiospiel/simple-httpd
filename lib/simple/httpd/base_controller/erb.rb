require "erb"

class Simple::Httpd::BaseController
  # A simple ERB renderer
  helpers do
    module ERB::Helpers
      def self.json(data)
        JSON.pretty_generate(data)
      end
    end

    def erb(template, data)
      content_type "text/html"

      erb = template.is_a?(ERB) ? template : ERB.new(template)
      data[:helpers] = ERB::Helpers
      erb.result_with_hash(data)
    end
  end
end
