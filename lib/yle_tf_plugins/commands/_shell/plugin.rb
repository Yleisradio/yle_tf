# frozen_string_literal: true

require 'yle_tf'

module YleTfPlugins
  module CommandShell
    class Plugin < YleTf::Plugin
      register

      command('_shell', 'Executes shell in the prepared environment') do
        require_relative 'command'
        YleTf::Action.default_action_stack(Command)
      end
    end
  end
end
