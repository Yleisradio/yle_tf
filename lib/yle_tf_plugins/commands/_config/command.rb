require 'yle_tf/logger'

module YleTfPlugins
  module CommandConfig
    class Command
      def execute(env)
        puts env[:config]
      end
    end
  end
end
