RackR - Use R in your Rack stack
================================

RackR is a Rack middleware which integrates R into a Rack based web
application (like Rails). With RackR in place displaying graphs is as
simple as rendering R code into your output. E.g.

    <script type='text/r'>
      png('sinus.png')
      plot(sin)
    </script>

RackR will pick this up on its way out and replace it with an empty
container and some JavaScript code to perform an immediate
asynchronous request for processing the R code.

RackR will answer to this request with processing the R code in a
temporary directory, then searching this directory for displayable
content, and finally return the html code for display. So the example
above will eventually turn into something like this:

    <div>
     <img src='/path/to/sinus.png' />
     <pre>
       content of Rout file (stdout of R)
     </pre>
    </div>

**Almost everything can conveniently be configured in a YAML file.**
RackR will create a sample config file in `config/rack-r.yml` or any
other path given.


Install in Rails
----------------

Put the following in your Gemfile and run `bundle`

    gem 'rack-r'


Use the TemplateHandler
-----------------------

You can create partials with the extension `.rackr` which will
automatically be picked up by the middleware.

    # render the file `_partial_with_r_code_inside.html.rackr`
    render :partial => 'partial_with_r_code_inside'


Combine R with HAML
-------------------

In HAML you can combine R and Ruby via the erb filter

    :erb
      sql = '<%= SomeModel.select(:value).to_sql %>'
      data = dbGetQuery(connect(), sql)
      boxplot(data$value)

1
Using RackR outside of Rails
----------------------------

    require 'rack_r/middleware'
    use RackR::Middleware, :config => 'path/to/config/rack-r.yml'


The RackR-Header
----------------

The RackR-Header is a piece of R code that gets prepended to every R
script, which is processed by RackR. Ideally it will read your
database config and provide a seperate connection to your database via
a DBI compatible object. This is currently provided by a R function
called `connect`.

If you want RackR to automatically connect R scripts to your Rails
database it is a good idea to install Jeremy Stephens' YAML for R, as
mentioned in Dependencies.

Additionally there is a function `getPapertrail` which takes a
classname and an id, and retrieves previous versions of database entries
(stored by the popular versioning library
[Papertrail](https://github.com/airblade/paper_trail/)) in form of a
proper R dataframe.

The whole RackR-Header is a work in progress, if you have to adjust it
to your database config and/or end up writing helper functions like
`getPapertrail`, please consider to contribute your additions.


Dependencies
------------

These instructions are for Debian Squeeze. Install R.

    apt-get install r-base r-cran-dbi

Alternatively to `dbi` you can use the `rodbc` package.

    apt-get install r-cran-rodbc 

Install additional packages from CRAN. Note: Only the latest version
is available. Check CRAN for the latest version.

### YAML

    wget http://cran.r-project.org/src/contrib/yaml_2.1.4.tar.gz
    R CMD INSTALL yaml_2.1.4.tar.gz


### SQLite

    wget http://cran.r-project.org/src/contrib/RSQLite_0.11.1.tar.gz
    R CMD INSTALL RSQLite_0.11.1.tar.gz

### MySQL

    apt-get install r-cran-rmysql


Trouble shooting
----------------

Browse to /rack-r/ (including the trailing slash!) to see if RackR is
working. If so it should respond with "RackR OK."


Patches and the like
--------------------

If you run into bugs, have suggestions or patches feel free to drop me
a line.


License
-------

RackR is released under MIT License, see LICENSE.
