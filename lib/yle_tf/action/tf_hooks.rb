# frozen_string_literal: true

require 'yle_tf/logger'
require 'yle_tf/tf_hook/runner'

require 'yle_tf/logger'
require 'yle_tf/tf_hook/runner'

class YleTf
  module Action
    class TfHooks
      def initialize(app)
        @app = app
      end

      def call(env)
        @env = env

        hook_runner.run('pre')
        @app.call(env)
        hook_runner.run('post')
      end

      def hook_runner
        if run_hooks?
          TfHook::Runner.new(@env[:config], hook_env)
        else
          NoRunner
        end
      end

      def hook_env
        {
          'TF_COMMAND' => @env[:tf_command],
          'TF_ENV'     => @env[:tf_env],
        }
      end

      def run_hooks?
        !@env[:tf_options][:no_hooks]
      end

      class NoRunner
        def self.run(hook_type)
          Logger.debug("Skipping #{hook_type} hooks due to `--no-hooks`")
        end
      end
    end
  end
end
