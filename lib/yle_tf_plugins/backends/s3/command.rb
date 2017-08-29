require 'yle_tf/backend_config'

module YleTfPlugins
  module Backends
    module S3
      class Command
        def backend_config(config)
          YleTf::BackendConfig.new(
            's3',
            'region' => config.fetch('backend', 'region'),
            'bucket' => config.fetch('backend', 'bucket'),
            'key' => config.fetch('backend', 'file'),
            'encrypt' => config.fetch('backend', 'encrypt')
          )
        end
      end
    end
  end
end
