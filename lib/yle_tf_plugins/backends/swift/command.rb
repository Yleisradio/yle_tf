require 'yle_tf/backend_config'

module YleTfPlugins
  module Backends
    module Swift
      class Command
        def backend_config(config)
          YleTf::BackendConfig.new(
            'swift',
            'region_name' => config.fetch('backend', 'region'),
            'container' => config.fetch('backend', 'container'),
            'archive_container' => config.fetch('backend', 'archive_container') { nil }
          )
        end
      end
    end
  end
end
