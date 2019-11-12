require_relative "./json"

# rubocop:disable Metrics/ClassLength

class Simple::Httpd::BaseController
  H = ::Simple::Httpd::Helpers

  set :show_exceptions, false
  set :dump_errors, false
  set :raise_errors, false

  set :raise_errors, true if ENV["RACK_ENV"] == "test"

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

    json options
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
    STDERR.puts "Caught ArgumentError: #{exc}, from\n\t#{exc.backtrace[0, 5].join("\n\t")}"

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

  error(NotAuthorizedError) do
    render_error e, status: 403,
                    title: "Not authorized",
                    description: "You don't have necessary powers to access this page."
  end

  def not_authorized!(msg)
    raise NotAuthorizedError, msg
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

  error do |exc|
    content_type :text
    message = <<~MSG
      === #{exc.class.name} =====================
      #{exc.message.chomp}

      #{filtered_backtrace(exc)}
      ==================================================================
    MSG

    STDERR.puts message
    status 500
    "\n#{message}\n"
  end

  private

  def error_type(exc)
    "error/#{H.underscore exc.class.name}".gsub(/\/error$/, "")
  end

  def error_description(exc)
    exc.message
    # "#{exc.message}, from #{exc.backtrace.join("\n\t")}"
  end

  def remove_wd(str)
    @wd ||= Dir.getwd

    if str.start_with?(@wd)
      str[(@wd.length + 1)..-1]
    else
      str
    end
  end

  def filtered_backtrace(exc, count: 20)
    lines = exc.backtrace.map do |line|
      next "...\n" if line =~ /\.rvm\b/

      "#{remove_wd(line)}\n"
    end

    s = lines[0, count].join("")
    s.gsub(/(\.\.\.\n)+/, "   ... (lines removed) ...\n")
  end
end
