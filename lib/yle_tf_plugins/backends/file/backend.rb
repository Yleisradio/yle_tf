# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'shellwords'

require 'yle_tf/backend'
require 'yle_tf/logger'
require 'yle_tf/system'

module YleTfPlugins
  module Backends
    module File
      class Backend < YleTf::Backend
        def configure
          if !encrypt?
            create_tfstate(tfstate_path)
            symlink_tfstate
          elsif tfstate_path.exist?
            decrypt_tfstate
          end
        end

        def tear_down
          encrypt_tfstate if encrypt? && local_tfstate_path.exist?
        end

        def create_tfstate(path)
          return if path.exist?

          YleTf::Logger.debug('Creating state file')
          path.write(tfstate_template, perm: 0o644)
        end

        def symlink_tfstate
          YleTf::Logger.info("Symlinking state to '#{tfstate_path}'")
          local_tfstate_path.make_symlink(tfstate_path)
        end

        def encrypt?
          config.fetch('backend', type, 'encrypt')
        end

        def decrypt_tfstate
          YleTf::Logger.info("Decrypting state from '#{tfstate_path}'")

          cmd = config.fetch('backend', type, 'decrypt_command')
          cmd.gsub!('{{FROM}}', tfstate_path.to_s)
          cmd.gsub!('{{TO}}', local_tfstate_path.to_s)

          # Split the command to have nicer logs
          YleTf::System.cmd(*Shellwords.split(cmd))
        end

        def encrypt_tfstate
          YleTf::Logger.info("Encrypting state to '#{tfstate_path}'")

          cmd = config.fetch('backend', type, 'encrypt_command')
          cmd.gsub!('{{FROM}}', local_tfstate_path.to_s)
          cmd.gsub!('{{TO}}', tfstate_path.to_s)

          YleTf::System.cmd(*Shellwords.split(cmd),
                            error_handler: method(:on_encrypt_error))
        end

        def on_encrypt_error(_exit_code, error)
          plain_tfstate_path = "#{tfstate_path}.plaintext"

          YleTf::Logger.warn("Copying unencrypted state to '#{plain_tfstate_path}'")
          FileUtils.cp(local_tfstate_path.to_s, plain_tfstate_path)

          raise error
        end

        def tfstate_path
          @tfstate_path ||= config.module_dir.join(config.fetch('backend', type, 'path'))
        end

        def local_tfstate_path
          @local_tfstate_path ||= Pathname.pwd.join('terraform.tfstate')
        end

        def tfstate_template
          '{"version": 1}'
        end
      end
    end
  end
end
