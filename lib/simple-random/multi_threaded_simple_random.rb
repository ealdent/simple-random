class MultiThreadedSimpleRandom < SimpleRandom
  class << self
    def instance
      # Thread variables are shared by fibers and collected with their owning thread.
      instances = Thread.current.thread_variable_get(:simple_random_instances)
      unless instances
        instances = {}
        Thread.current.thread_variable_set(:simple_random_instances, instances)
      end

      instances[self] ||= new
    end
  end

  private_class_method :new
end
