# frozen_string_literal: true

require 'yle_tf/config'

class YleTf
  module Action
    class LoadConfig
      def initialize(app)
        @app = app
      end

      def call(env)
        env[:config] ||= Config.new(env[:tf_env])

        @app.call(env)
      end
    end
  end
end
