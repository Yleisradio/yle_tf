require 'yle_tf/config/defaults'
require 'yle_tf/config/erb'
require 'yle_tf/config/file'
require 'yle_tf/logger'
require 'yle_tf/plugin'

require_relative '../../../vendor/hash_deep_merge'

class YleTf
  class Config
    class Loader
      include Config::Defaults

      attr_reader :tf_env, :module_dir

      def initialize(opts)
        @tf_env = opts.fetch(:tf_env)
        @module_dir = opts.fetch(:module_dir)
      end

      def load
        Logger.debug('Loading default config')
        config = default_config
        Logger.debug(config.inspect)

        Logger.debug('Merging default configurations from plugins')
        merge_plugin_configurations(config)
        Logger.debug(config.inspect)

        Logger.debug('Merging configurations from files')
        merge_config_files(config)
        Logger.debug(config.inspect)

        Logger.debug('Evaluating the configuration strings')
        eval_config(config)
      end

      def config_context
        @config_context ||= load_config_context
      end

      def load_config_context
        Logger.debug('Loading config context')
        default_config_context.tap do |context|
          Logger.debug('Merging configuration contexts from plugins')
          merge_plugin_config_contexts(context)
          Logger.debug("config_context: #{context.inspect}")
        end
      end

      def merge_plugin_config_contexts(context)
        Plugin.manager.config_contexts.each do |plugin_context|
          context.merge!(plugin_context)
        end
      end

      def merge_plugin_configurations(config)
        Plugin.manager.default_configs.each do |plugin_config|
          deep_merge(
            config, plugin_config,
            error_msg:
              "Failed to merge a plugin's default configuration:\n" \
              "#{plugin_config.inspect}\ninto:\n#{config.inspect}"
          )
        end
      end

      def merge_config_files(config)
        config_files do |file|
          Logger.debug("  - #{file}")
          deep_merge(
            config, file.read,
            error_msg:
              "Failed to merge configuration from '#{file}' into:\n" \
              "#{config.inspect}"
          )
        end
      end

      def deep_merge(config, new_config, opts = {})
        config.deep_merge!(new_config)
      rescue StandardError => e
        Logger.fatal(opts[:error_msg]) if opts[:error_msg]
        raise e
      end

      def config_files
        module_dir.descend do |dir|
          file = dir.join('tf.yaml')
          yield(Config::File.new(file)) if file.exist?
        end
      end

      def eval_config(config)
        case config
        when Hash
          config.each_with_object({}) { |(key, value), h| h[key] = eval_config(value) }
        when Array
          config.map { |item| eval_config(item) }
        when String
          Config::ERB.evaluate(config, config_context)
        else
          config
        end
      end
    end
  end
end
