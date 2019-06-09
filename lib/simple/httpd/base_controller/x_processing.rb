# Simple::SQL connection handling
class Simple::Httpd::BaseController
  before do
    @processing_started_at = Time.now
  end

  after do
    runtime = Time.now - @processing_started_at
    headers "X-Processing" => runtime.to_s
  end
end
