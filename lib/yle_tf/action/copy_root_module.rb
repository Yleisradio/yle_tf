# frozen_string_literal: true

require 'fileutils'

require 'yle_tf/logger'

class YleTf
  module Action
    class CopyRootModule
      def initialize(app)
        @app = app
      end

      def call(env)
        config = env[:config]

        Logger.debug("Copying the Terraform module from '#{config.module_dir}' to '#{Dir.pwd}'")
        FileUtils.cp_r("#{config.module_dir}/.", '.')

        @app.call(env)
      end
    end
  end
end
