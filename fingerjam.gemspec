# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fingerjam/version"

Gem::Specification.new do |s|
  s.name        = "fingerjam"
  s.version     = Fingerjam::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Hoeksema"]
  s.email       = ["steve@seven.net.nz"]
  s.homepage    = "https://github.com/steveh/fingerjam"
  s.summary     = %q{Fingerprinting for Jammit}
  s.description = %q{Fingerjam uploads your Jammit-compressed assets with fingerprinted filenames so they can be cached indefinitely}

  s.rubyforge_project = "fingerjam"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency(%q<rails>, ["~> 3.0"])
  s.add_runtime_dependency(%q<jammit>, ["~> 1.6"])
  s.add_runtime_dependency(%q<capistrano>, ["~> 2.5"])
  s.add_runtime_dependency(%q<activesupport>, ["~> 3.0"])
  s.add_runtime_dependency(%q<actionpack>, ["~> 3.0"])

  s.add_development_dependency(%q<rspec>, ["~> 2.5"])
  s.add_development_dependency(%q<bundler>, ["~> 1.0"])
  s.add_development_dependency(%q<rcov>, [">= 0"])
end