# frozen_string_literal: true

class YleTf
  class Plugin
    autoload :ActionHook, 'yle_tf/plugin/action_hook'
    autoload :Loader, 'yle_tf/plugin/loader'
    autoload :Manager, 'yle_tf/plugin/manager'

    DEFAULT_BACKEND = Object.new.freeze
    DEFAULT_COMMAND = Object.new.freeze

    def self.manager
      @manager ||= Manager.new
    end

    def self.register
      Plugin.manager.register(self)
    end

    def self.action_hooks
      @action_hooks ||= []
    end

    def self.action_hook(&block)
      action_hooks << block
    end

    def self.commands
      @commands ||= {}
    end

    def self.command(name, synopsis, &block)
      name = name.to_s if name.is_a?(Symbol)
      commands[name] = {
        synopsis: synopsis,
        proc:     block
      }
    end

    def self.default_config(config = nil)
      @default_config = config if config
      @default_config || {}
    end

    def self.config_context(context = nil)
      @config_context = context if context
      @config_context || {}
    end

    def self.backends
      @backends ||= {}
    end

    def self.backend(type, &block)
      type = type.to_s if type.is_a?(Symbol)
      backends[type] = block
    end
  end
end
