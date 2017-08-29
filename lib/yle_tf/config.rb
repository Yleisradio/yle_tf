require 'pathname'
require 'yaml'

require 'yle_tf/config/loader'
require 'yle_tf/error'
require 'yle_tf/logger'

class YleTf
  # Configuration object to be used especially by the middleware stack
  class Config
    NotFoundError = Class.new(Error)

    attr_reader :config, :tf_env, :module_dir

    def initialize(tf_env)
      Logger.debug("Initializing configuration for the #{tf_env.inspect} environment")

      @tf_env = tf_env
      @module_dir = Pathname.pwd
      @config = Loader.new(tf_env: tf_env, module_dir: module_dir).load

      Logger.debug(inspect)
    end

    def to_s
      YAML.dump(config)
    end

    # Returns a value from the configuration hierarchy specified by a list of
    # keys. If the key is not specified, return result of a specied block, or
    # raise `NotFoundError` if none specified.
    def fetch(*keys, &block)
      block ||= DEFAULT_NOT_FOUND_BLOCK

      keys.inject(config) do |conf, key|
        break block.call(keys) if !conf || !conf.key?(key)
        conf[key]
      end
    end

    DEFAULT_NOT_FOUND_BLOCK = lambda do |keys|
      raise NotFoundError, "Configuration key not found: #{keys.join(' > ')}"
    end.freeze
  end
end
