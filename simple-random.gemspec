# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "simple-random"
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["John D. Cook", "Jason Adams"]
  s.date = "2026-02-18"
  s.description = "Simple Random Number Generator including Beta, Cauchy, Chi square, Exponential, Gamma, Inverse Gamma, Laplace (double exponential), Normal, Student t, Uniform, and Weibull.  Ported from John D. Cook's C# Code."
  s.email = "jasonmadams@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/simple-random.rb",
    "lib/simple-random/multi_threaded_simple_random.rb",
    "lib/simple-random/simple_random.rb",
    "simple-random.gemspec",
    "test/helper.rb",
    "test/test_simple_random.rb"
  ]
  s.homepage = "http://github.com/ealdent/simple-random"
  s.licenses = ["CDDL-1.0"]
  s.summary = "Simple Random Number Generator"

  s.add_development_dependency("minitest", [">= 0"])
  s.add_development_dependency("shoulda", [">= 0"])
  s.add_development_dependency("rake", [">= 0"])
  s.add_development_dependency("simplecov", [">= 0"])
end
