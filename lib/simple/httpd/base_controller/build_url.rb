require "cgi"

class Simple::Httpd::BaseController
  helpers do
    def base_url
      @base_url ||= request.base_url
    end

    def full_url(path, opts = {})
      build_url(base_url, path, opts)
    end

    def url(path, opts = {})
      build_url(path, opts)
    end

    def build_url(base, *args)
      option_args, string_args = args.partition { |arg| arg.is_a?(Hash) }
      options = option_args.inject({}) { |hsh, option| hsh.update option }

      url = File.join([base] + string_args)

      query = build_url_query(options)
      url += url.index("?") ? "&#{query}" : "?#{query}" if query
      url
    end

    private

    def build_url_query(params)
      params = params.reject { |_k, v| v.nil? || v.to_s.empty? }
      return nil if params.empty?

      params.map { |k, value| "#{k}=#{escape(value.to_s)}" }.join("&")
    end
  end
end
