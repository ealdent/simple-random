class SimpleRandom
  def initialize
    @m_w = 521288629
    @m_z = 362436069
  end

  def set_seed(*args)
    if args.size > 1
      @m_w = args.first.to_i if args.first.to_i != 0
      @m_z = args.last.to_i if args.last.to_i != 0
    elsif args.first.is_a?(Numeric)
      @m_w = args.first.to_i if args.first.to_i != 0
    elsif args.first.is_a?(Time)
      x = args.first.to_i
      @m_w = x >> 16
      @m_z = x % 4294967296 # 2 ** 32
    else
      x = Time.now.to_i
      @m_w = x >> 16
      @m_z = x % 4294967296 # 2 ** 32
    end
  end

  # Produce a uniform random sample from the open interval (lower, upper).
  # The method will not return either end point.
  def uniform(lower = 0, upper = 1)
    raise 'Invalid range' if upper <= lower
    ((get_unsigned_int + 1) * 2.328306435454494e-10 * (upper - lower)) + lower
  end

  # Sample normal distribution with given mean and standard deviation
  def normal(mean = 0.0, standard_deviation = 1.0)
    raise 'Invalid standard deviation' if standard_deviation <= 0
    mean + standard_deviation * ((-2.0 * Math.log(uniform)) ** 0.5) * Math.sin(2.0 * Math::PI * uniform)
  end

  # Get exponential random sample with specified mean
  def exponential(mean = 1)
    raise 'Mean must be positive' if mean <= 0
    -1.0 * mean * Math.log(uniform)
  end

  # Implementation based on "A Simple Method for Generating Gamma Variables"
  # by George Marsaglia and Wai Wan Tsang.  ACM Transactions on Mathematical Software
  # Vol 26, No 3, September 2000, pages 363-372.
  def gamma(shape, scale)
    if shape >= 1.0
      d = shape - 1.0 / 3.0
      c = 1 / ((9 * d) ** 0.5)
      while true
        v = 0.0
        while v <= 0.0
          v = 1.0 + c * normal
        end
        v = v ** 3
        u = uniform
        if u < (1.0 - 0.0331 * (x ** 4)) || Math.log(u) < (0.5 * (x ** 2) + d * (1.0 - v + Math.log(v)))
          return scale * d * v
        end
      end
    elsif shape <= 0.0
      raise 'Shape must be positive'
    else
      g = gamma(shape + 1.0, 1.0)
      w = uniform
      return scale * g * (w ** (1.0 / shape))
    end
  end

  def chi_square(degrees_of_freedom)
    gamma(0.5 * degrees_of_freedom, 2.0)
  end

  def inverse_gamma(shape, scale)
    1.0 / gamma(shape, 1.0 / scale)
  end

  def weibull(shape, scale)
    raise 'Shape and scale must be positive' if shape <= 0.0 || scale <= 0.0

    scale * ((-Math.log(uniform)) ** (1.0 / shape))
  end

  def cauchy(median, scale)
    raise 'Scale must be positive' if scale <= 0

    median + scale * Math.tan(Math::PI * (uniform - 0.5))
  end

  def student_t(degrees_of_freedom)
    raise 'Degrees of freedom must be positive' if degrees_of_freedom <= 0

    normal / ((chi_square(degrees_of_freedom) / degrees_of_freedom) ** 0.5)
  end

  def laplace(mean, scale)
    u = uniform
    mean + Math.log(2) + ((u < 0.5 ? 1 : -1) * scale * Math.log(u < 0.5 ? u : 1 - u))
  end

  def log_normal(mu, sigma)
    Math.exp(normal(mu, sigma))
  end

  private

  # This is the heart of the generator.
  # It uses George Marsaglia's MWC algorithm to produce an unsigned integer.
  # See http://www.bobwheeler.com/statistics/Password/MarsagliaPost.txt
  def get_unsigned_int
    @m_z = 36969 * (@m_z & 65535) + (@m_z >> 16);
    @m_w = 18000 * (@m_w & 65535) + (@m_w >> 16);
    (@m_z << 16) + (@m_w & 65535)
  end
end