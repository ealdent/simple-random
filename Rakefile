require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "simple-random"
    gem.summary = %Q{Simple Random Number Generator}
    gem.description = %Q{Simple Random Number Generator including Beta, Cauchy, Chi square, Exponential, Gamma, Inverse Gamma, Laplace (double exponential), Normal, Student t, Uniform, and Weibull.  Ported from John D. Cook's C# Code.}
    gem.email = "jasonmadams@gmail.com"
    gem.homepage = "http://github.com/ealdent/simple-random"
    gem.authors = ["John D. Cook", "Jason Adams"]
    gem.add_development_dependency "shoulda", "~> 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :test => :check_dependencies

task :default => :test
