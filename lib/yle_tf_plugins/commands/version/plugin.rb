require 'yle_tf'

module YleTfPlugins
  module CommandVersion
    class Plugin < YleTf::Plugin
      register

      command('version', 'Prints the version information') do
        require_relative 'command'

        YleTf::Action::Builder.new do
          use YleTf::Action::TmpDir
          use YleTf::Action::Command, Command
        end
      end
    end
  end
end
