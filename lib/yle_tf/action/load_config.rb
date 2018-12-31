# frozen_string_literal: true

require 'yle_tf/config'
require 'yle_tf/logger'

class YleTf
  module Action
    class LoadConfig
      def initialize(app)
        @app = app
      end

      def call(env)
        env[:config] ||= load_config(env[:tf_env])

        @app.call(env)
      end

      def load_config(tf_env)
        Logger.debug("Initializing configuration for the #{tf_env.inspect} environment")
        Config.load(tf_env).tap { |config| Logger.debug(config.inspect) }
      end
    end
  end
end
