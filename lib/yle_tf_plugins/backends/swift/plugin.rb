# frozen_string_literal: true

require 'yle_tf'

module YleTfPlugins
  module Backends
    module Swift
      class Plugin < YleTf::Plugin
        register

        backend('swift') do
          require_relative 'command'
          Command
        end
      end
    end
  end
end
