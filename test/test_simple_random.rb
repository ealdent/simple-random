# TODO: use Kolmogorov-Smirnov test instead: http://en.wikipedia.org/wiki/Kolmogorov_Smirnov

require 'helper'

SAMPLE_SIZE = 10000
MAXIMUM_EPSILON = 0.01

def generate_numbers(generator, distribution, *args)
  (1..SAMPLE_SIZE).map { generator.send(distribution.to_sym, *args) }
end

class Array
  def mean
    if size > 0
      inject(0.0) { |sum, i| sum + i } / size.to_f
    else
      0.0
    end
  end

  def standard_deviation
    if size > 1
      m = mean
      (inject(0.0) { |sum, i| sum + ((i - m) ** 2) } / (size - 1).to_f) ** 0.5
    else
      1.0
    end
  end
end

class TestSimpleRandom < Test::Unit::TestCase
  context "A simple random number generator" do
    setup do
      @r = SimpleRandom.instance
    end

    should "generate random numbers from a uniform distribution in the interval (0, 1)" do
      SAMPLE_SIZE.times do
        u = @r.uniform
        assert u < 1
        assert u > 0
      end
    end

    should "generate uniformly random numbers with mean approximately 0.5" do
      numbers = generate_numbers(@r, :uniform)
      epsilon = (0.5 - numbers.mean).abs

      assert epsilon < MAXIMUM_EPSILON
    end

    should "generate random numbers from a normal distribution with mean approximately 0" do
      numbers = generate_numbers(@r, :normal)
      epsilon = (0.0 - numbers.mean).abs

      assert epsilon < MAXIMUM_EPSILON
    end

    should "generate random numbers from a normal distribution with sample standard deviation approximately 1" do
      numbers = generate_numbers(@r, :normal)
      epsilon = (1.0 - numbers.standard_deviation).abs

      assert epsilon < MAXIMUM_EPSILON
    end

    should "generate random numbers from an exponential distribution with mean approximately 1" do
      numbers = generate_numbers(@r, :exponential)
      epsilon = (1.0 - numbers.mean).abs

      assert epsilon < MAXIMUM_EPSILON
    end

    should "generate a random number sampled from a gamma distribution" do
      assert @r.gamma(5, 2.3)
    end

    should "generate a random number sampled from an inverse gamma distribution" do
      assert @r.inverse_gamma(5, 2.3)
    end

    should "generate a random number sampled from a beta distribution" do
      assert @r.beta(5, 2.3)
    end

    should "generate a random number sampled from a chi-square distribution" do
      assert @r.chi_square(10)
    end

    should "generate a random number using weibull" do
      assert @r.weibull(5, 2.3)
    end

    should "work independently in every thread" do
      sample_count = 10
      thread_count = 10

      samples = Hash.new { |hash, key| hash[key] = [] }

      threads = Array.new(thread_count) do
        Thread.new do
          sample_count.times do
            samples[Thread.current.object_id] << SimpleRandom.instance.uniform
          end
        end
      end

      threads.map(&:join)

      samples = samples.values
      assert samples.size == thread_count
      assert samples.uniq.size == 1
    end

  end
end
