# rubocop:disable Metrics/ClassLength, Lint/Void
# rubocop:disable Metrics/AbcSize

require_relative "./json"

# reimplement Sinatra's NotFound handler.
#
# The original renders HTML; this is not really useful for us.
Sinatra::Base
class Sinatra::Base
  error ::Sinatra::NotFound do
    content_type "text/plain"

    "Don't know how to handle: #{request.request_method} '#{request.path_info}'"
  end
end

class Simple::Httpd::BaseController
  H = ::Simple::Httpd::Helpers

  set :show_exceptions, false
  set :dump_errors, false
  set :raise_errors, false

  private

  def stringify_hash(hsh)
    return unless hsh

    hsh.inject({}) do |r, (k, v)|
      k = k.to_s if k.is_a?(Symbol)
      r.update k => v
    end
  end

  public

  def render_error(exc, options)
    expect! options => {
      status: Integer,
      title: String,
      description: [String, nil]
    }

    status options[:status]

    options = stringify_hash(options)
    options["description"] ||= options["title"]
    options["@type"] = error_type(exc)
    options["@now"] = Time.now.to_f
    options["@request"] = "#{request.request_method} #{request.path}"

    if Simple::Httpd.env == "development" || Simple::Httpd.env == "test"
      options["@headers"] = request_headers_for_debugging
      options["@backtrace"] = exc.backtrace[0, 10]
    end

    json options
  end

  def request_headers_for_debugging
    request.headers.each_with_object({}) do |(key, value), hsh|
      next if /^(Host|Version|Connection|User-Agent|Accept-Encoding)$/ =~ key
      next if key == "Accept" && value == "*/*"

      hsh[key] = value
    end
  end

  if defined?(Expectation)

    error(Expectation::Matcher::Mismatch) do |exc|
      render_error exc, status: 400,
                        title: "Invalid input",
                        description: error_description(exc)
    end

  end

  # class InvalidRequest < RuntimeError
  # end
  #
  # error(InvalidRequest) do |e|
  #   render_error e, status: 400,
  #                title: "Invalid input",
  #                description: error_description(e)
  # end

  error(ArgumentError) do |exc|
    render_error exc, status: 422,
                      title: "Invalid input #{exc.inspect}",
                      description: error_description(exc)
  end

  error(::Simple::Service::ArgumentError) do |exc|
    render_error exc, status: 422,
                      title: "Invalid input #{exc.message}",
                      description: exc.message
  end

  # -- not authorized.---------------------------------------------------------

  class NotAuthorizedError < RuntimeError
  end

  def not_authorized!(msg)
    raise NotAuthorizedError, msg
  end

  error(NotAuthorizedError) do
    render_error e, status: 403,
                    title: "Not authorized",
                    description: "You don't have necessary powers to access this page."
  end

  # -- login required.---------------------------------------------------------

  class LoginRequiredError < RuntimeError
  end

  def login_required!(msg)
    raise LoginRequiredError, msg
  end

  error(LoginRequiredError) do
    render_error e, status: 404,
                    title: "Not found",
                    description: "The server failed to recognize affiliation. Please provide a valid Session-Id."
  end

  # -- resource not found.-----------------------------------------------------

  class NotFoundError < RuntimeError
  end

  def not_found!(msg)
    raise NotFoundError, msg
  end

  error(NotFoundError) do |exc|
    render_error exc, status: 404,
                      title: "Not found",
                      description: error_description(exc)
  end

  error(Errno::ENOENT) do |exc|
    render_error exc, status: 404,
                      title: "Not found",
                      description: "The requested record was not found."
  end

  # -- print unspecified errors.

  if ::Simple::Httpd.env != "development"
    error do |exc|
      content_type :text
      status 500
      exc.class.name
    end
  else
    error do |exc|
      content_type :text
      message = <<~MSG
        === #{exc.class.name} =====================
        #{exc.message.chomp}

        #{H.filtered_stacktrace(exc.backtrace).join("\n")}
        ==================================================================
      MSG

      STDERR.puts message
      status 500
      "\n#{message}\n"
    end
  end

  private

  def error_type(exc)
    "error/#{H.underscore exc.class.name}".gsub(/\/error$/, "")
  end

  def error_description(exc)
    exc.message
    # "#{exc.message}, from #{exc.backtrace.join("\n\t")}"
  end
end
