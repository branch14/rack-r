$:.push File.expand_path("../lib", __FILE__)
require "rack_r/version"

Gem::Specification.new do |s|
  s.name        = "rack-r"
  s.version     = RackR::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Phil Hofmann"]
  s.email       = ["phil@branch14.org"]
  s.homepage    = "http://branch14.org/rack-r"
  s.summary     = %q{Use R in your Rack stack}
  s.description = %q{Use R in your Rack stack}

  # s.rubyforge_project = "rack-r"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "rails"]
end
