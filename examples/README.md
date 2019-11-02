# An example

This directory contains an example application. (Well, this example is probably not as *useful* for any purpose, but I hope it demonstrates all simple-httpd use cases, also it is used during tests.)

See [its readme](examples/README.md) for more details.

## How to start the example application

Assuming you have installed the simple-httpd gem via `gem install simple-httpd` you should be able to start the server via

    simple-httpd --port=12345 ex1 ex2 v2:api/v2

This starts a HTTPD server on `http://0.0.0.0:12345`. The server serves content from the `./ex1` and `./ex2` directories at the root URL (`http://0.0.0.0:12345/`) and content from the ./v2 directory below `http://0.0.0.0:12345/api/v2`.

The following explanations assume you started a server with the configuration mentioned above.

## Files

This directory currently contains these files:

    - ex1/root.rb
    - ex1/ex1_helpers.rb
    - ex2/helpers.rb
    - ex2/root.rb
    - ex2/info.rb
    - ex2/ex2_helpers.rb
    - ex2/README.txt
    - v2/root.rb
    - v2/jobs.rb
    - v2/v2_helpers.rb
    - v2/api.js

## Some routes

The following lists some routes and where they are implemented:

  GET "/"                         .. in ex1/root.rb
  GET "/debug"                    .. in ex2/root.rb
  GET "/info/inspect"             .. in ex2/info.rb
  GET "/api/v2/"                  .. in v2/root.rb
  GET "/api/v2/jobs/:id/events"   .. in v2/jobs.rb
