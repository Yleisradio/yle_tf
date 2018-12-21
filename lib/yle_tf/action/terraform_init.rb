# frozen_string_literal: true

require 'yle_tf/logger'
require 'yle_tf/plugin'
require 'yle_tf/system'

class YleTf
  module Action
    class TerraformInit
      TF_CMD_ARGS = %w[-input=false -no-color].freeze

      TF_CMD_OPTS = {
        env:    { 'TF_IN_AUTOMATION' => 'true' }, # Reduces some output
        stdout: :debug                            # Hide the output to the debug level
      }.freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        config = env[:config]
        backend = backend(config)

        Logger.info('Initializing Terraform')
        Logger.debug("Backend configuration: #{backend}")

        init(backend)

        @app.call(env)
      end

      def init(backend)
        Logger.debug('Configuring the backend')
        backend.configure

        Logger.debug('Initializing Terraform')
        YleTf::System.cmd('terraform', 'init', *TF_CMD_ARGS, TF_CMD_OPTS)
      end

      def backend(config)
        backend_type = config.fetch('backend', 'type').downcase
        backend_proc = Plugin.manager.backends[backend_type]

        klass = backend_proc.call
        klass.new(config)
      end
    end
  end
end
