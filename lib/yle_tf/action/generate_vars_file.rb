require 'yle_tf/logger'
require 'yle_tf/vars_file'

class YleTf
  module Action
    class GenerateVarsFile
      def initialize(app)
        @app = app
      end

      def call(env)
        config = env[:config]

        Logger.debug("Generating 'terraform.tfvars'")
        vars_file = VarsFile.new('terraform.tfvars')
        vars_file.append_vars(tfvars(env))
        vars_file.append_file(VarsFile.find_env_vars_file(config))

        @app.call(env)
      end

      def tfvars(env)
        env[:tfvars].merge(env[:config].fetch('tfvars'))
      end
    end
  end
end
