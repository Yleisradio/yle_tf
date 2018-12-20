# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

require 'yle_tf/logger'

class YleTf
  module Action
    class TmpDir
      def initialize(app)
        @app = app
      end

      def call(env)
        config = env[:config]

        tmpdir = Dir.mktmpdir(tmpdir_prefix(config))
        Logger.debug("Temporary Terraform directory: #{tmpdir}")

        Dir.chdir(tmpdir) do
          @app.call(env)
        end
      ensure
        FileUtils.rm_r(tmpdir) if tmpdir && Dir.exist?(tmpdir)
      end

      def tmpdir_prefix(config)
        if config
          "tf_#{config.module_dir.basename}_#{config.tf_env}_"
        else
          'tf_'
        end
      end
    end
  end
end
