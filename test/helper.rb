if ENV["COVERAGE"]
  require 'simplecov'

  module SimpleCov::Configuration
    def clean_filters
      @filters = []
    end
  end

  SimpleCov.configure do
    clean_filters
    load_profile 'test_frameworks'
  end

  SimpleCov.start do
    add_filter "/.rvm/"
  end
end

require 'time'
require 'minitest/autorun'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'simple-random'
