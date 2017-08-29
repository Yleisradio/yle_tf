require 'yle_tf'

module YleTfPlugins
  module CommandConfig
    class Plugin < YleTf::Plugin
      register

      command('_config', 'Prints the evaluated configuration') do
        require_relative 'command'

        YleTf::Action::Builder.new do
          use YleTf::Action::LoadConfig
          use YleTf::Action::VerifyTfEnv
          use YleTf::Action::Command, Command
        end
      end
    end
  end
end
