require 'yle_tf/error'
require 'yle_tf/logger'
require 'yle_tf/plugin'
require 'yle_tf/system'
require 'yle_tf/version_requirement'

class YleTf
  module Action
    class TerraformInit
      def initialize(app)
        @app = app
      end

      def call(env)
        config = env[:config]
        backend = backend_config(config)

        Logger.info('Initializing Terraform')
        Logger.debug("Backend configuration: #{backend}")

        if VersionRequirement.pre_0_9?(env[:terraform_version])
          init_pre_0_9(backend)
        else
          init(backend)
        end

        @app.call(env)
      end

      def init_pre_0_9(backend)
        cli_args = backend.cli_args
        if cli_args
          YleTf::System.cmd('terraform', 'remote', 'config',
                            '-no-color', *cli_args,
                            stdout: :debug)
        end

        Logger.debug('Fetching Terraform modules')
        YleTf::System.cmd('terraform', 'get', '-no-color', stdout: :debug)
      end

      def init(backend)
        Logger.debug('Generating the backend configuration')
        backend.generate_config do
          Logger.debug('Initializing Terraform')
          YleTf::System.cmd('terraform', 'init', '-no-color', stdout: :debug)
        end
      end

      def backend_config(config)
        backend_type = config.fetch('backend', 'type').downcase
        backend_proc = backend_proc(backend_type)

        klass = backend_proc.call
        klass.new.backend_config(config)
      end

      def backend_proc(backend_type)
        backends = Plugin.manager.backends
        backends.fetch(backend_type.to_sym) do
          raise Error, "Unknown backend type '#{backend_type}'. " \
            "Supported backends: #{backends.keys.join(', ')}"
        end
      end
    end
  end
end
