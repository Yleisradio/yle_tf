# frozen_string_literal: true

require 'yle_tf'

module YleTfPlugins
  module Backends
    module File
      class Plugin < YleTf::Plugin
        register

        backend('file') do
          require_relative 'backend'
          Backend
        end
      end
    end
  end
end
