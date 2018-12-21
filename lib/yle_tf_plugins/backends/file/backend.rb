# frozen_string_literal: true

require 'pathname'
require 'yle_tf/backend'
require 'yle_tf/logger'

module YleTfPlugins
  module Backends
    module File
      class Backend < YleTf::Backend
        # Symlinks local "terraform.tfstate" to the specified path
        def configure
          YleTf::Logger.info("Symlinking state to '#{tfstate_path}'")
          local_path = Pathname.pwd.join('terraform.tfstate')
          local_path.make_symlink(tfstate_path)

          tfstate_path.write(tfstate_template, perm: 0o644) if !tfstate_path.exist?
        end

        def tfstate_path
          @tfstate_path ||= config.module_dir.join(config.fetch('backend', 'file', 'path'))
        end

        def tfstate_template
          '{"version": 1}'
        end
      end
    end
  end
end
