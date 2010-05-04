require 'helper'

class TestSimpleRandom < Test::Unit::TestCase
  context "A simple random number generator" do
    setup do
      @r = SimpleRandom.new
    end

    should "generate random numbers from a uniform distribution" do
      1000.times do
        u = @r.uniform
        assert u < 1
        assert u > 0
      end
    end
  end
end
