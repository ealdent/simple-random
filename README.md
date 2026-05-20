# simple-random [![CI](https://github.com/ealdent/simple-random/actions/workflows/ci.yml/badge.svg)](https://github.com/ealdent/simple-random/actions/workflows/ci.yml)

Generate random numbers sampled from the following distributions:

* Beta
* Cauchy
* Chi square
* Dirichlet
* Exponential
* Gamma
* Inverse gamma
* Laplace (double exponential)
* Normal
* Student t
* Triangular
* Uniform
* Weibull

Based on [John D. Cook's SimpleRNG](http://www.codeproject.com/KB/recipes/SimpleRNG.aspx) C# library.

## Installation

### Plain Ruby

Run `gem install simple-random` in your terminal.

### Ruby on Rails

Add `gem 'simple-random', '~> 1.0.0'` to your Gemfile and run `bundle install`.


## Usage

Some of the methods available:

``` ruby
    > r = SimpleRandom.new                 # Initialize a SimpleRandom instance
     => #<SimpleRandom:0x007f9e3ad58010 @m_w=521288629, @m_z=362436069>
    > r.set_seed                           # By default the same random seed is used, so we change it
    > r.uniform(0, 5)                      # Produce a uniform random sample from the open interval (lower, upper).
     => 0.6353204359766096
    > r.normal(1000, 200)                  # Sample normal distribution with given mean and standard deviation
     => 862.5447157384566
    > r.exponential(2)                     # Get exponential random sample with specified mean
     => 0.9386480625062965
    > r.triangular(0, 2.5, 10)             # Get triangular random sample with specified lower limit, mode, upper limit
     => 3.1083306054169277
```

Note that by default the same seed is used every time to generate the random numbers.  This means that repeated runs should yield the same results.  If you would like it to always initialize with a different seed, or if you are using multiple SimpleRandom objects, you should call `#set_seed` on the instance.

See [lib/simple-random.rb](lib/simple-random/simple_random.rb) for all available methods and options.


## Development

Install the development dependencies with Bundler:

``` sh
bundle install
```

Run the test suite:

``` sh
bundle exec rake test
```

Build the gem locally:

``` sh
bundle exec rake build
```

Generate local coverage output when needed:

``` sh
bundle exec rake simplecov
```

GitHub Actions runs the test suite and gem build on Ruby 2.6 and Ruby 3.0 through 3.4.

## Contributing

* Fork the project.
* Make your feature addition or bug fix.
* Add or update tests for behavioral changes.
* Run `bundle exec rake test` before opening a pull request.
* Keep release-only files such as `VERSION` and `simple-random.gemspec` unchanged unless the pull request is specifically preparing a release.
* Send a pull request.

The project uses plain Bundler, Rake, and GitHub Actions. It no longer uses Jeweler, Travis CI, or Code Climate.

## Copyright

Distributed under the Code Project Open License, which is similar to MIT or BSD.  See LICENSE for full details (don't just take my word for it that it's similar to those licenses).

## History

### 1.0.5 - 2026-05-20
* Remove development dependency metadata from the published gemspec

### 1.0.4 - 2026-02-18
* Remove vulnerable development dependency declarations for `bundler` and `rdoc`
* Replace obsolete Jeweler/RDoc release tasks with a plain gem build task
* Use `https://rubygems.org` as the gem source in development

### 1.0.3 - 2015-11-25
* Attempt to reduce code complexity and improve readability
* Change error handling somewhat to throw specific errors and improve messages

### 1.0.2 - 2015-11-24
* Merge pull request from [cunchem](https://github.com/cunchem) to fix Laplace method

### 1.0.1 - 2015-07-31
* Merge [purcell](https://github.com/purcell)'s changes to fix numeric seeds

### 1.0.0 - 2014-07-08
* Migrate to new version of Jeweler for gem packaging
* Merge [jwroblewski](https://github.com/jwroblewski)'s changes into a new multi-threaded simple random class
* Change from Code Project Open License to [CDDL-1.0](http://opensource.org/licenses/CDDL-1.0)

### 0.10.0 - 2014-03-31
* Sample from triangular distribution (thanks to [benedictleejh](https://github.com/benedictleejh))

### 0.9.3 - 2011-09-16
* Sample from Dirichlet distribution with given set of parameters

### 0.9.2 - 2011-09-06
* Use microseconds for random seed

### 0.9.1 - 2010-07-27
* First stable release
