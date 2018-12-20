# frozen_string_literal: true

require 'yle_tf'

module YleTfPlugins
  module CommandHelp
    class Plugin < YleTf::Plugin
      register

      command('help', 'Prints this help') do
        require_relative 'command'

        YleTf::Action::Builder.new do
          use YleTf::Action::TmpDir
          use YleTf::Action::Command, Command
        end
      end
    end
  end
end
