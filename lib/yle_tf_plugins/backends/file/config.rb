# frozen_string_literal: true

require 'yle_tf/backend_config'

module YleTfPlugins
  module Backends
    module File
      class Config < YleTf::BackendConfig
        def generate_config
          yield if block_given?
        end

        def cli_args
          nil
        end
      end
    end
  end
end
