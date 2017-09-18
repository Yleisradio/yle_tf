require 'yle_tf/logger'

class YleTf
  class Plugin
    module Loader
      BUNDLER_PLUGIN_GROUP = :tf_plugins

      def self.load_plugins
        load_core_plugins
        load_bundler_plugins
        load_user_plugins
      end

      def self.load_core_plugins
        core_plugins.each do |plugin_file|
          Logger.debug("Loading core plugin: #{File.basename(plugin_file, '.rb')}")
          load(plugin_file)
        end
      end

      def self.load_bundler_plugins
        return if !bundler_set_up?

        print_bundler_plugin_list if Logger.debug?
        Bundler.require(BUNDLER_PLUGIN_GROUP)
      end

      def self.load_user_plugins
        user_plugins.each do |plugin|
          Logger.debug("Loading user plugin: #{plugin}")
          require(plugin)
        end
      end

      def self.core_plugins
        Dir.glob(File.expand_path('../../../yle_tf_plugins/**/plugin.rb', __FILE__))
      end

      def self.bundler_plugins
        plugins = Bundler.definition.current_dependencies.select do |dep|
          dep.groups.include?(BUNDLER_PLUGIN_GROUP)
        end
        plugins.map { |dep| Bundler.definition.specs[dep].first }
      end

      def self.user_plugins
        ENV.fetch('TF_PLUGINS', '').split(/[ ,]+/)
      end

      def self.bundler_set_up?
        defined?(Bundler) && Bundler.respond_to?(:require)
      end

      def self.print_bundler_plugin_list
        plugins = bundler_plugins
        if !plugins.empty?
          Logger.debug('Loading plugins via Bundler:')
          plugins.each { |spec| Logger.debug("  - #{spec.name} = #{spec.version}") }
        end
      end
    end
  end
end
