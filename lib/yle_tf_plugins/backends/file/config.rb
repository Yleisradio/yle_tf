# frozen_string_literal: true

require 'yle_tf/backend_config'

module YleTfPlugins
  module Backends
    module File
      class Config < YleTf::BackendConfig
        def generate_config
          # Do nothing, as the state file is just symlinked
        end
      end
    end
  end
end
