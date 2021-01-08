# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'shellwords'

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

      attr_reader :config

      def initialize(app)
        @app = app
      end

      def call(env)
        @config = env[:config]

        Logger.info('Initializing Terraform')
        Logger.debug("Backend configuration: #{backend}")

        init_dir(backend)

        if env[:tf_command] == 'init'
          # Skip initializing Terraform here, as it will be done by the
          # actuall command later in the middleware stack.
          @app.call(env)
          store_terraform_lock
        else
          init_terraform
          store_terraform_lock
          @app.call(env)
        end
      end

      def init_dir(backend)
        Logger.debug('Configuring the backend')
        backend.configure

        Logger.debug('Symlinking errored.tfstate')
        symlink_to_module_dir('errored.tfstate')
      end

      def init_terraform
        Logger.debug('Initializing Terraform')
        YleTf::System.cmd('terraform', 'init', *tf_init_args, **TF_CMD_OPTS)
      end

      def store_terraform_lock
        Logger.debug('Storing .terraform.lock.hcl')
        copy_to_module_dir('.terraform.lock.hcl')
      end

      def backend
        @backend ||= find_backend
      end

      def tf_init_args
        TF_CMD_ARGS + Shellwords.split(ENV.fetch('TF_INIT_ARGS', ''))
      end

      def find_backend
        backend_type = config.fetch('backend', 'type').downcase
        backend_proc = Plugin.manager.backends[backend_type]

        klass = backend_proc.call
        klass.new(config)
      end

      def symlink_to_module_dir(file)
        local_path = Pathname.pwd.join(file)
        remote_path = config.module_dir.join(file)

        # Remove the possibly copied old file
        local_path.unlink if local_path.exist?

        local_path.make_symlink(remote_path)
      end

      def copy_to_module_dir(file)
        FileUtils.cp(file, config.module_dir.to_s) if File.exist?(file)
      end
    end
  end
end
