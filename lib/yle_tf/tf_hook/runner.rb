# frozen_string_literal: true

require 'yle_tf/logger'
require 'yle_tf/tf_hook'

class YleTf
  class TfHook
    class Runner
      attr_reader :config, :hook_env

      def initialize(config, hook_env)
        @config = config
        @hook_env = hook_env
      end

      def tf_env
        @tf_env ||= config.tf_env
      end

      def run(hook_type)
        Logger.debug("Running #{hook_type} hooks")
        hooks(hook_type).each do |hook|
          hook.run(hook_env)
        end
      end

      def hooks(hook_type)
        hook_confs(hook_type).map { |conf| TfHook.from_config(conf, tf_env) } +
          hook_files(hook_type).map { |file| TfHook.from_file(file) }
      end

      def hook_confs(hook_type)
        config.fetch('hooks', hook_type).select do |hook|
          if hook['envs'] && !hook['envs'].include?(tf_env)
            Logger.debug("Skipping hook '#{hook['description']}' in env '#{tf_env}'")
            false
          else
            true
          end
        end
      end

      def hook_files(hook_type)
        Dir.glob("tf_hooks/#{hook_type}/*").select do |file|
          File.executable?(file) && !File.directory?(file)
        end
      end
    end
  end
end
