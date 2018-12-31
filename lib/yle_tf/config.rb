# frozen_string_literal: true

require 'pathname'
require 'yaml'

require 'yle_tf/config/loader'
require 'yle_tf/error'

class YleTf
  # Configuration object to be used especially by the middleware stack
  class Config
    NotFoundError = Class.new(Error)

    # Loads the configuration based on the environment
    def self.load(tf_env)
      opts = {
        tf_env:     tf_env,
        module_dir: Pathname.pwd
      }

      config = Loader.new(opts).load
      new(config, opts)
    end

    attr_reader :config, :tf_env, :module_dir

    def initialize(config, **opts)
      @config = config
      @tf_env = opts[:tf_env]
      @module_dir = opts[:module_dir]
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
        break block.call(keys) if conf.nil? || !conf.is_a?(Hash) || !conf.key?(key)

        conf[key]
      end
    end

    DEFAULT_NOT_FOUND_BLOCK = lambda do |keys|
      raise NotFoundError, "Configuration key not found: #{keys.join(' > ')}"
    end.freeze
  end
end
