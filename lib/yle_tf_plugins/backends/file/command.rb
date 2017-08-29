require_relative 'config'

module YleTfPlugins
  module Backends
    module File
      class Command
        def backend_config(config)
          local_path = Pathname.pwd.join('terraform.tfstate')
          tfstate_path = tfstate_path(config)

          YleTf::Logger.info("Symlinking state to '#{tfstate_path}'")
          local_path.make_symlink(tfstate_path)
          tfstate_path.write(tfstate_template, perm: 0o644) if !tfstate_path.exist?

          Config.new(
            'file',
            'file' => tfstate_path.to_s
          )
        end

        def tfstate_path(config)
          config.module_dir.join(config.fetch('backend', 'file'))
        end

        def tfstate_template
          '{"version": 1}'
        end
      end
    end
  end
end
