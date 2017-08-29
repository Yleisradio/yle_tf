require 'yle_tf/logger'

class YleTf
  class Plugin
    class Manager
      attr_reader :registered

      def initialize
        @registered = []
      end

      def register(plugin)
        if !registered.include?(plugin)
          Logger.debug("Registered plugin: #{plugin}")
          @registered << plugin
        end
      end

      def action_hooks
        registered.map(&:action_hooks).flatten
      end

      def commands
        {}.tap do |commands|
          registered.each do |plugin|
            commands.merge!(plugin.commands)
          end
          commands.default = commands.delete(DEFAULT_COMMAND)
        end
      end

      def config_contexts
        registered.map(&:config_context)
      end

      def default_configs
        registered.map(&:default_config)
      end

      def backends
        {}.tap do |backends|
          registered.each do |plugin|
            backends.merge!(plugin.backends)
          end
        end
      end
    end
  end
end
