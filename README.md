RackR - Use R in your Rack stack
================================

Install in Rails
----------------

Put the following in your Gemfile and run `bundle install` or let
[Guard](https://github.com/guard/guard-bundler) kick in.

    gem 'rack-r'

Using RackR outside of Rails
----------------------------

    require 'rack_r/middleware'
    use RackR::Middleware, :config => 'path/to/config/rack-r.yml'

Configure
---------

RackR will create a sample config file in `config/rack-r.yml`.

Dependencies
------------

    apt-get install r-base

Patches and the like
--------------------

If you run into bugs, have suggestions, patches or want to use RackR
with something else than Rails feel free to drop me a line.

License
-------

RackR is released under MIT License, see LICENSE.