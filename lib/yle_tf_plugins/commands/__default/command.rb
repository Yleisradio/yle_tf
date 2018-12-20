# frozen_string_literal: true

require 'yle_tf/logger'
require 'yle_tf/system'

module YleTfPlugins
  module CommandDefault
    class Command
      def execute(env)
        command = env[:tf_command]

        args = env[:tf_command_args].dup
        args << '-no-color' if !color?(env)

        YleTf::Logger.info "Running `terraform #{command}`"
        YleTf::System.console_cmd('terraform', command, *args)
      end

      def color?(env)
        !env[:tf_options][:no_color]
      end
    end
  end
end
