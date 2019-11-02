# simple-httpd – serving HTTP made simpler.

This ruby gem wraps around [sinatra](/) to provide an even simpler way of setting up http based backends. It is especially helpful to:

- bind loosely related pieces of code together: `simple-httpd` lets a developer lay out their code and assets in directories and trees of directories and can then serve these via HTTP.  
- have an easy way to serve static assets via HTTP.
- allow existing applications, especially CLI tools, to easily start HTTP servers.

In some ways one might be reminded of the web's old days where one would throw a bunch of php scripts into a FTP location, and then an appache webserver (but, really, its php integration) would start serving requests via HTTPS. ***simple-httpd* is not like that.** This gem still supports the notion of an application; source files typically rely on other source files' existence and functionality.

Also, at least as of now, **simple-httpd** does not dynamically reload code parts on request. This might change in the future.

## Is it useful?

At this point I don't know yet. We'll see. In any case this gem is used to test [rspec-httpd](github.com/radiospiel/rspec-httpd) (a rspec extension helping with testing HTTP endpoints), and is used within [postjob-httpd](github.com/radiospiel/postjob-httpd) where it is configured to glue HTTP endpoints to the [postjob](github.com/radiospiel/postjob) job queue system.

It has proven useful so far - but as it is a really lean wrapper around sinatra one might probably also use sinatra in most cases.

## Mounting directories

`simple-httpd` lets a user of the gem "mount" directories onto "mount points". A "mount point" describes the location of the actions or static assets at the HTTP endpoint. Note that two or more directories can be mounted at the same mount point.

Files in a mounted directory fall into different categories:

### Static assets

Static assets are files with a predefined set of file extensions, including `.txt` and `.js`. (compare the `static_mount.rb` source file for a full list.)

They become available at the location specified by their filename and extension.

### Dynamic assets

Each mounted directory which contains ruby source files is converted into a sinatra application, which consists of a root configuration and controllers for each action file.

Ruby files ending in `_helpers.rb`, e.g. `examples/ex1/ex1_helpers.rb` are executed in the context of a directory tree's root controller and provide functionality available in all action files. Typically they do not implement HTTP handlers themselves.

All other ruby files implement HTTP handlers in typical sinatra fashion:

    # in v2/jobs.rb
    get "/queue/:id/events" do
      events = [
        { job_id: params[:id], id: "event1" },
        { job_id: params[:id], id: "event2" }
      ]
    
      json events
    end

If this snippet is contained in a file `v2/jobs.rb` and the `v2` directory is mounted into `api/v2`, the snipped implements the handler for, for example, `GET /api/v2/jobs/queue/123/events`. In other words, the handler implement in the source file works on paths relative to a path combining the mount location and the file name.

To implement a action on the mountpoint itself one uses the `root.rb` file. The following

    # in v2/root.rb
    get "/" do
      json version: "123"
    end

would implement `GET /api/v2`.

## Command line usage

`simple-httpd` comes with a CLI tool, which lets one assemble multiple locations into a single HTTP backend: the following command serves the *./ex1* and *./ex2* directories at `http://0.0.0.0:12345` and the *./v2* directory at `http://0.0.0.0:12345/api/v2`.

    simple-httpd --port=12345 ex1 ex2 v2:api/v2

The `v2:api/v2` argument asks the `v2` directory to be mounted into the web endpoint at `/api/v2`. All relevant content is therefore served below `http://0.0.0.0:12345/api/v2`.

The arguments `ex1` and `ex2` serve at the `/` location. This notation really is a shorthand for `ex1:/` 

## Integration

`simple-httpd` can be integrated into other ruby scripts. Example:

    require "simple-httpd"

    httpd_root_dir = File.join(__dir__, "httpd")
    port = 12345

    app = ::Simple::Httpd.build("/" => httpd_root_dir)
    ::Simple::Httpd.listen! app, port: port,
                                 logger: ::Logger.new(STDERR)


## The example application

An example application is contained in ./examples. (Well, this example is probably not as *useful* for any purpose, but I hope it demonstrates all simple-httpd use cases, also it is used during tests.)

See [its readme](examples/README.md) for more details.
