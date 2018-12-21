# frozen_string_literal: true

require 'yle_tf/config/defaults'
require 'yle_tf/config/erb'
require 'yle_tf/config/file'
require 'yle_tf/config/migration'
require 'yle_tf/helpers/hash'
require 'yle_tf/logger'
require 'yle_tf/plugin'

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
        load_sequence = %i[
          load_default_config
          load_plugin_configurations
          load_config_files
          evaluate_configuration_strings
        ]
        load_sequence.inject({}) { |config, method| send(method, config) }
      end

      def load_default_config(_config)
        task('Loading default config') { default_config }
      end

      def load_plugin_configurations(config)
        Logger.debug('Loading configuration from plugins')

        plugins.inject(config) do |prev_config, plugin|
          migrate_and_merge_configuration(prev_config, plugin.default_config,
                                          type: 'plugin', name: plugin.to_s)
        end
      end

      def load_config_files(config)
        Logger.debug('Loading configuration from files')

        config_files.inject(config) do |prev_config, file|
          migrate_and_merge_configuration(prev_config, file.read,
                                          type: 'file', name: file.name)
        end
      end

      def evaluate_configuration_strings(config)
        task('Evaluating the configuration strings') { eval_config(config) }
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

      def plugins
        Plugin.manager.registered
      end

      def config_files
        module_dir.descend.lazy
                  .map { |dir| dir.join('tf.yaml') }
                  .select(&:exist?)
                  .map { |file| Config::File.new(file) }
      end

      def migrate_and_merge_configuration(prev_config, config, **opts)
        task("- #{opts[:name]}") { config }
        return prev_config if config.empty?

        source = "#{opts[:type]}: '#{opts[:name]}'"
        config = migrate_old_config(config, source: source)
        deep_merge(prev_config, config, source: source)
      end

      def migrate_old_config(config, **opts)
        task('  -> Migrating') do
          Config::Migration.migrate_old_config(config, opts)
        end
      end

      def deep_merge(prev_config, config, **opts)
        task('  -> Merging') do
          Helpers::Hash.deep_merge(prev_config, config)
        end
      rescue StandardError => e
        Logger.fatal("Failed to merge configuration from #{opts[:source]}:\n" \
                     "#{config.inspect}\ninto:\n#{prev_config.inspect}")
        raise e
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

      # Helper to print debug information about the task and configuration
      # after it
      def task(message = nil)
        Logger.debug(message) if message

        yield.tap do |config|
          Logger.debug("  #{config.inspect}")
        end
      end
    end
  end
end
