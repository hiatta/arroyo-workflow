require "uuidtools"
require "threadz"
require 'singleton'

class ParticipantThreadPoolManager
  include Singleton
  
  # This is a map of engines to maps of participant regexes (as used by Ruote to match participants) to thread pools
  attr_reader :pools
  
  DEFAULT_MIN_THREADS=5
  DEFAULT_MAX_THREADS=50
  
  VALID_OPTS = [
    :max_threads,
    :min_threads
  ]

  def initialize
    @pools={}
    @mutex=Mutex.new
  end

  def generate_pool_key
    UUIDTools::UUID.random_create.to_s
  end

  def get_pool(pool_key)
    raise StandardError, "pool_key must be set" unless pool_key
    return @pools[pool_key]
  end
  
  def create_pool(opts={})
    raise StandardError, "opts must be set as a hash object" unless opts and opts.is_a?(Hash)
    max_threads = opts[:max_threads] || DEFAULT_MAX_THREADS
    min_threads = opts[:min_threads] || [opts[:max_threads] || DEFAULT_MIN_THREADS, DEFAULT_MIN_THREADS].min
    raise StandardError, "max_threads must be greater than 0" if max_threads < 1
    raise StandardError, "min_threads must be greater than or equal to 0" if min_threads < 0
    raise StandardError, "max_threads must be greater than or equal to min_threads" if max_threads < min_threads

    pool_key=generate_pool_key
    @mutex.synchronize do
      @pools[pool_key] ||= Threadz::ThreadPool.new(initial_size: min_threads , maximum_size: max_threads)
    end
    return pool_key
  end
end