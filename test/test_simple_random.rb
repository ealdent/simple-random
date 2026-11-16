require 'helper'
require 'timeout'
require 'weakref'

# TODO: use Kolmogorov-Smirnov test instead: http://en.wikipedia.org/wiki/Kolmogorov_Smirnov

SAMPLE_SIZE = 10000
MAXIMUM_EPSILON = 0.01

def generate_numbers(generator, distribution, *args)
  (1..SAMPLE_SIZE).map { generator.send(distribution.to_sym, *args) }
end

class Array
  def mean
    if size > 0
      inject(&:+) / size.to_f
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

def Time.now
  new(2015, 11, 26, 12, 1, 15, '-05:00')
end

class TestSimpleRandom < Minitest::Test
  context "Setting the seeds for a simple random number generator" do
    context "on initialization" do
      should "assign default seeds when none are specified" do
        r = SimpleRandom.new
        assert r.seeds == SimpleRandom::DEFAULT_SEEDS
      end

      should "assign the seeds specified in the initializer" do
        r = SimpleRandom.new(1, 2)
        assert r.seeds == [1, 2]
      end

      should "reject negative seed values" do
        assert_raises SimpleRandom::InvalidSeedArgument do
          SimpleRandom.new(-1, 3)
        end
      end
    end

    context 'after initialization' do
      setup do
        @r = SimpleRandom.new
      end

      should "accept a single value and leave the first seed the same" do
        @r.seeds = 1
        assert @r.seeds == [521288629, 1]
      end

      should "update the seeds when given an array of values" do
        @r.seeds = [1, 2]
        assert @r.seeds == [1, 2]
      end

      should "accept a timestamp instead of an numeric value" do
        @r.seeds = Time.parse('2015-01-01T00:00:00.000-0500')
        assert @r.seeds == [193992865, 413250560]
      end

      should "use the current timestamp when nothing is specified" do
        @r.seeds = nil
        assert @r.seeds == [628393424, 2245012672]
      end
    end

    should "provide different results with different integer seeds" do
      r1 = SimpleRandom.new
      r1.set_seed(2)
      r2 = SimpleRandom.new
      r2.set_seed(1234512343214134)

      r1_randoms = 100.times.map { r1.uniform(0, 10).floor }
      r2_randoms = 100.times.map { r2.uniform(0, 10).floor }

      assert r1_randoms != r2_randoms
    end
  end

  context "A simple random number generator" do
    setup do
      @r = SimpleRandom.new
    end

    should "generate random numbers from a uniform distribution in the interval (0, 1)" do
      SAMPLE_SIZE.times do
        u = @r.uniform
        assert u < 1
        assert u > 0
      end
    end

    should "exclude the upper bound even with fixed-point seeds" do
      r = SimpleRandom.new(1179647999, 2422800383)

      3.times do
        assert_operator r.uniform, :>, 0
        assert_operator r.uniform, :<, 1
        assert_operator r.uniform(-5, 5), :<, 5
      end
    end

    should "preserve seeded samples away from the upper endpoint" do
      expected = [0.12706408719532192, 0.46806520386599004, 0.9058290126267821]
      assert_equal expected, Array.new(3) { @r.uniform }
    end

    should "preserve finite seeded samples with nondefault bounds" do
      expected = [0.12541281743906438, 0.19361304077319802, 0.2811658025253564]
      assert_equal expected, Array.new(3) { @r.uniform(0.1, 0.3) }
    end

    should "preserve distinct draws across wide finite intervals" do
      [
        [0.0, 1e308],
        [-1e308, 0.0],
        [-Float::MAX, Float::MAX],
        [Float::MAX / 2, Float::MAX],
        [-Float::MAX, -Float::MAX / 2]
      ].each do |lower, upper|
        generator = SimpleRandom.new
        reference = SimpleRandom.new

        samples = Array.new(3) do
          sample = generator.uniform(lower, upper)
          # Exact rational arithmetic supplies an independent interpolation reference.
          expected = (lower.to_r + reference.uniform.to_r * (upper.to_r - lower.to_r)).to_f

          assert sample.finite?
          assert_operator sample, :>, lower
          assert_operator sample, :<, upper
          assert_in_delta expected, sample, expected.abs * 1e-14
          sample
        end

        assert_equal 3, samples.uniq.size
      end
    end

    should "preserve extreme seeded draws across the widest finite interval" do
      samples = [
        SimpleRandom.new(1179647999, 2422800383),
        SimpleRandom.new(4294967296, 4294967296)
      ].map do |generator|
        sample = generator.uniform(-Float::MAX, Float::MAX)

        assert sample.finite?
        assert_operator sample, :>, -Float::MAX
        assert_operator sample, :<, Float::MAX
        sample
      end

      assert_operator samples.first, :>, 0
      assert_operator samples.last, :<, 0
    end

    should "exclude rounded endpoints for narrow bounds with an offset" do
      generators = [
        SimpleRandom.new(1179647999, 2422800383),
        SimpleRandom.new(4294967296, 4294967296)
      ]

      [[1.0, 1.00000001], [-1.00000001, -1.0]].each do |lower, upper|
        generators.each do |generator|
          sample = generator.uniform(lower, upper)
          assert_operator sample, :>, lower
          assert_operator sample, :<, upper
        end
      end
    end

    should "return the only representable interior float when bounds are very close" do
      lower = 1.0
      interior = lower.next_float
      upper = interior.next_float

      assert_equal interior, SimpleRandom.new(1179647999, 2422800383).uniform(lower, upper)
      assert_equal interior, SimpleRandom.new(4294967296, 4294967296).uniform(lower, upper)
    end

    should "keep samples inside integer bounds that round during float conversion" do
      lower = 2 ** 53 + 3
      upper = 2 ** 53 + 5
      sample = SimpleRandom.new(1179647999, 2422800383).uniform(lower, upper)

      assert_operator sample, :>, lower
      assert_operator sample, :<, upper
    end

    should "reject bounds with no representable interior float" do
      [[1.0, 1.0.next_float], [-1.0, (-1.0).next_float], [0.0, 0.0.next_float]].each do |lower, upper|
        assert_raises(ArgumentError) { @r.uniform(lower, upper) }
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

    should "generate random numbers from triangular(0, 1, 1) in the range [0, 1]" do
      SAMPLE_SIZE.times do
        t = @r.triangular(0.0, 1.0, 1.0)
        assert t <= 1.0
        assert t >= 0.0
      end
    end

    should "generate random numbers from triangular(0, 1, 1) with mean approximately 0.66" do
      a = 0.0
      c = 1.0
      b = 1.0
      numbers = generate_numbers(@r, :triangular, a, c, b)
      mean = (a + b + c) / 3
      epsilon = (mean - numbers.mean).abs

      assert epsilon < MAXIMUM_EPSILON
    end

    should "generate random numbers from triangular(0, 1, 1) with standard deviation approximately 0.23" do
      a = 0.0
      b = 1.0
      c = 1.0
      numbers = generate_numbers(@r, :triangular, a, b, c)
      std_dev = Math.sqrt((a ** 2 + b ** 2 + c ** 2 - a * b - a * c - b * c) / 18)
      epsilon = (std_dev - numbers.standard_deviation).abs

      assert epsilon < MAXIMUM_EPSILON
    end

    should "generate random numbers from triangular(0, 0.5, 1) with mean approximately 0.5" do
      a = 0.0
      b = 0.5
      c = 1.0

      numbers = generate_numbers(@r, :triangular, a, b, c)
      mean = (a + b + c) / 3
      epsilon = (mean - numbers.mean).abs

      assert epsilon < MAXIMUM_EPSILON
    end

    should "generate a random number sampled from a gamma distribution" do
      assert @r.gamma(5, 2.3)
      assert @r.gamma(5.3, 2.7)
      assert @r.gamma(2.3, 2)
    end

    should "reject gamma shapes that cannot be represented as finite floats" do
      [Float::INFINITY, -Float::INFINITY, Float::NAN, 10 ** 400].each do |shape|
        Timeout.timeout(2) do
          assert_raises(ArgumentError) { @r.gamma(shape, 1) }
        end
      end
    end

    should "reject infinite shapes in distributions that use gamma" do
      [
        [:chi_square, Float::INFINITY],
        [:inverse_gamma, Float::INFINITY, 1],
        [:beta, 1, Float::INFINITY],
        [:student_t, Float::INFINITY],
        [:dirichlet, 1, Float::INFINITY]
      ].each do |method, *args|
        Timeout.timeout(2) do
          assert_raises(ArgumentError) { @r.public_send(method, *args) }
        end
      end
    end

    should "finish gamma sampling with fixed-point seeds" do
      r = SimpleRandom.new(1179647999, 2422800383)

      Timeout.timeout(2) do
        [0.5, 1, 5].each do |shape|
          sample = r.gamma(shape, 1)
          assert sample.finite?
          assert_operator sample, :>, 0
        end
      end
    end

    should "generate a random number sampled from an inverse gamma distribution" do
      assert @r.inverse_gamma(5, 2.3)
      assert @r.inverse_gamma(5.7, 2.8)
      assert @r.inverse_gamma(3.2, 2)
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

    should "generate random number from a dirichlet distribution" do
      assert @r.dirichlet(5.3, 2.7)
    end

    should "generate random numbers from laplace(0, 1) with mean approximately 0" do
      mean = 0.0
      scale = 0.1
      numbers = generate_numbers(@r, :laplace, mean, scale)
      epsilon = (mean - numbers.mean).abs

      assert epsilon < MAXIMUM_EPSILON
    end
  end

  context "A multi-threaded simple random number generator" do
    setup do
      @r = MultiThreadedSimpleRandom.instance
    end

    should "reuse the same generator across calls and fibers in one thread" do
      assert_same @r, MultiThreadedSimpleRandom.instance
      assert_same @r, Fiber.new { MultiThreadedSimpleRandom.instance }.resume
    end

    should "keep generators separate between threads and subclasses" do
      other = Thread.new { MultiThreadedSimpleRandom.instance }.value
      subclass = Class.new(MultiThreadedSimpleRandom)

      refute_same @r, other
      assert_instance_of subclass, subclass.instance
      assert_same subclass.instance, subclass.instance
      refute_same @r, subclass.instance
    end

    should "allow generators from finished threads to be garbage collected" do
      references = Array.new(20) do
        Thread.new { WeakRef.new(MultiThreadedSimpleRandom.instance) }.value
      end

      3.times { GC.start }

      assert references.none?(&:weakref_alive?)
    end

    should "work independently in every thread" do
      sample_count = 10
      thread_count = 10

      samples = Hash.new { |hash, key| hash[key] = [] }

      threads = Array.new(thread_count) do
        Thread.new do
          sample_count.times do
            samples[Thread.current.object_id] << MultiThreadedSimpleRandom.instance.uniform
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
