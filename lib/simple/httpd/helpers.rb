module Simple::Httpd::Helpers
  extend self

  def underscore(str)
    parts = str.split("::")
    parts = parts.map do |part|
      part.gsub(/[A-Z]+/) { |ch| "_#{ch.downcase}" }.gsub(/^_/, "")
    end
    parts.join("/")
  end
end
