require 'yle_tf'

module YleTfPlugins
  module Backends
    module File
      class Plugin < YleTf::Plugin
        register

        backend('file') do
          require_relative 'command'
          Command
        end
      end
    end
  end
end
