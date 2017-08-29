require 'yle_tf/system'

module YleTfPlugins
  module CommandDefault
    class Command
      def execute(env)
        command = env[:tf_command]
        args    = env[:tf_command_args]

        YleTf::System.cmd('terraform', command, *args)
      end
    end
  end
end
