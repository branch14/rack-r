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
container and some JavaScript code to perform an immediate async
request for processing the R code.

RackR will answer to this reqyest with processing the R code in a temp
directory, then searching this directory for displayable content and
finally return the html code for display. So the example above will
eventually turn into something like this.

    <div>
     <img src='/path/to/sinus.png' />
     <pre>
       content of Rout file (stdout of R)
     </pre>
    </div>

Almost everything can conveniently be configured in a YAML file. RackR
will create a sample config file in `config/rack-r.yml` or any other
path given.


Install in Rails
----------------

Put the following in your Gemfile and run `bundle install` or let
[Guard](https://github.com/guard/guard-bundler) kick in.

    gem 'rack-r', :require => 'rack_r'


Using RackR outside of Rails
----------------------------

    require 'rack_r/middleware'
    use RackR::Middleware, :config => 'path/to/config/rack-r.yml'


Dependencies
------------

These instructions are for Debian Squeeze. Install R.

    apt-get install r-base r-cran-rodbc r-cran-dbi

If you want RackR to automatically connect R script to yoyr Rails
database it is a goog udea to install Jeremy Stephens' YAML for R.

    wget http://cran.r-project.org/src/contrib/yaml_2.1.4.tar.gz
    R CMD INSTALL yaml_2.1.4.tar.gz


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