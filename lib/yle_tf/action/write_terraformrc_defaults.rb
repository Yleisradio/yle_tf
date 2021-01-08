# frozen_string_literal: true

require 'fileutils'
require 'pathname'

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
        if rc_file.exist?
          Logger.debug("Terraform configuration file '#{RC_PATH}' already exists")
          if !existing_keys.include?('plugin_cache_dir')
            Logger.warn("'plugin_cache_dir' not configured in '#{RC_PATH}'")
          end
        else
          Logger.debug("Writing default configuration to '#{RC_PATH}'")
          write_default_config
        end

        @app.call(env)
      end

      def rc_file
        @rc_file ||= Pathname.new(RC_PATH).expand_path
      end

      def existing_keys
        @existing_keys ||= [].tap do |keys|
          rc_file.readlines.each do |line|
            # The matcher is a bit naive, but enough for out use
            keys << Regexp.last_match(1) if line =~ /^(.+?)[ \t]*=/
          end
        end
      end

      def write_default_config
        rc_file.open('w') do |rc_file|
          configure_checkpoint(rc_file)
          configure_plugin_cache_dir(rc_file)
        end
      end

      def configure_checkpoint(file)
        Logger.info("Disabling Terraform upgrade and security bulletin checks by '#{RC_PATH}'")

        file.puts('disable_checkpoint = true')
      end

      def configure_plugin_cache_dir(file)
        Logger.info("Configuring global Terraform plugin cache by '#{RC_PATH}'")
        # Replace `~` with `$HOME` as it is not expanded correctly in all architectures.
        # Can't use `$HOME` in the constant though, as it won't be expanded by
        # `expand_path` below. Can't win this game.
        file.puts("plugin_cache_dir   = \"#{DEFAULT_PLUGIN_CACHE_PATH.sub(/^~/, '$HOME')}\"")

        dir = File.expand_path(DEFAULT_PLUGIN_CACHE_PATH)
        return if File.directory?(dir)

        Logger.debug("Creating the plugin cache dir '#{dir}'")
        FileUtils.mkdir_p(dir)
      end
    end
  end
end
