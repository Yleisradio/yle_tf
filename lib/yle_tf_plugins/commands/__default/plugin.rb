require 'yle_tf'

module YleTfPlugins
  module CommandDefault
    class Plugin < YleTf::Plugin
      register

      command(DEFAULT_COMMAND, 'Calls Terraform with the given subcommand') do
        require_relative 'command'
        YleTf::Action.default_action_stack(Command)
      end
    end
  end
end
