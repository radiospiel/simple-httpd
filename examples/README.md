This directory contains an example application. It is also used to run specs.

## How to run

Executing

    bin/simple-httpd --environment=test --port=12345 ex1 ex2 v2:api/v2

starts a HTTPD server on http://0.0.0.0:12345. The server serves content from the ./ex1 and ./ex2 directories at http://0.0.0.0:12345/ and content from the ./v2 directory below http://0.0.0.0:12345/api/v2.

The following lists some routes and where they aere implement:

  GET "/"                         .. in ex1/root.rb
  GET "/debug"                    .. in ex2/root.rb
  GET "/info/inspect"             .. in ex2/info.rb
  GET "/api/v2/"                  .. in v2/root.rb
  GET "/api/v2/jobs/:id/events"   .. in v2/jobs.rb
