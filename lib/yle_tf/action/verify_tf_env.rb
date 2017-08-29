require 'yle_tf/error'
require 'yle_tf/vars_file'

class YleTf
  module Action
    class VerifyTfEnv
      def initialize(app)
        @app = app
      end

      def call(env)
        config = env[:config]
        all_envs = VarsFile.list_all_envs(config)

        if !all_envs.include?(config.tf_env)
          raise Error, "Terraform vars file not found for the '#{config.tf_env}' " \
            " environment. Existing envs: #{all_envs.join(', ')}"
        end

        @app.call(env)
      end
    end
  end
end
