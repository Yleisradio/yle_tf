# frozen_string_literal: true

require 'fileutils'
require 'yle_tf/logger'

class YleTf
  module Action
    class WriteTerraformrcDefaults
      # Path of the Terraform CLI configuration file
      RC_PATH = '~/.terraformrc'

      # Path of the plugin cache directory
      DEFAULT_PLUGIN_CACHE_PATH = '~/.terraform.d/plugin-cache'

      def initialize(app)
        @app = app
      end

      def call(env)
        Logger.debug("Writing default configuration to '#{RC_PATH}'")
        open_rc_file do |rc_file|
          keys = existing_keys(rc_file)

          configure_checkpoint(rc_file) if !keys.include?('disable_checkpoint')
          configure_plugin_cache_dir(rc_file) if !keys.include?('plugin_cache_dir')
        end

        @app.call(env)
      end

      def open_rc_file(&block)
        File.open(File.expand_path(RC_PATH), 'a+', &block)
      end

      def existing_keys(rc_file)
        [].tap do |keys|
          rc_file.each_line do |line|
            keys << Regexp.last_match(1) if line =~ /^(.+?)[ \t]*=/
          end
        end
      end

      def configure_checkpoint(rc_file)
        Logger.info("Disabling Terraform upgrade and security bulletin checks by '#{RC_PATH}'")

        rc_file.puts('disable_checkpoint = true')
      end

      def configure_plugin_cache_dir(rc_file)
        Logger.info("Configuring global Terraform plugin cache by '#{RC_PATH}'")
        rc_file.puts("plugin_cache_dir   = \"#{DEFAULT_PLUGIN_CACHE_PATH}\"")

        dir = File.expand_path(DEFAULT_PLUGIN_CACHE_PATH)
        return if File.directory?(dir)

        Logger.debug("Creating the plugin cache dir '#{dir}'")
        FileUtils.mkdir_p(dir)
      end
    end
  end
end
