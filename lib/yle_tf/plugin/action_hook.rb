class YleTf
  class Plugin
    class ActionHook
      attr_reader :actions

      def initialize(actions)
        @actions = actions
      end

      def before(existing, new, *args, &block)
        if actions.include?(existing)
          actions.insert_before(existing, new, *args, &block)
        end
      end

      def after(existing, new, *args, &block)
        if actions.include?(existing)
          actions.insert_after(existing, new, *args, &block)
        end
      end
    end
  end
end
