require 'yle_tf'

module YleTfPlugins
  module Backends
    module S3
      class Plugin < YleTf::Plugin
        register

        backend('s3') do
          require_relative 'command'
          Command
        end
      end
    end
  end
end
