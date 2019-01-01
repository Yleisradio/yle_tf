# frozen_string_literal: true

require 'yle_tf'
require 'yle_tf/backend'

module YleTfPlugins
  module Backends
    module Default
      class Plugin < YleTf::Plugin
        register

        backend(DEFAULT_BACKEND) do
          YleTf::Backend
        end
      end
    end
  end
end
