![Build status](https://travis-ci.org/ealdent/simple-random.svg?branch=master)

# simple-random

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

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Distributed under the Code Project Open License, which is similar to MIT or BSD.  See LICENSE for full details (don't just take my word for it that it's similar to those licenses).

## History

### 1.0.0 - 2014-07-08
* Migrate to new version of Jeweler for gem packaging
* Merge jwroblewski's changes into a new multi-threaded simple random class
* Change from Code Project Open License to [CDDL-1.0](http://opensource.org/licenses/CDDL-1.0)

### 0.10.0 - 2014-03-31
* Sample from triangular distribution (thanks to [benedictleejh](https://github.com/benedictleejh))

### 0.9.3 - 2011-09-16
* Sample from Dirichlet distribution with given set of parameters

### 0.9.2 - 2011-09-06
* Use microseconds for random seed

### 0.9.1 - 2010-07-27
* First stable release
