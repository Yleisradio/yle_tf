require 'yle_tf/logger'
require 'yle_tf/version'

class YleTf
  autoload :Action,  'yle_tf/action'
  autoload :Error,   'yle_tf/error'
  autoload :Plugin,  'yle_tf/plugin'

  attr_reader :tf_env, :tf_command, :tf_command_args, :tf_options
  attr_writer :actions

  def initialize(tf_options, tf_env, tf_command, tf_command_args = [])
    Logger.debug("YleTf version: #{VERSION}")
    Logger.debug("Ruby version: #{RUBY_VERSION}")
    Logger.debug("tf_options: #{tf_options.inspect}")
    Logger.debug("tf_env: #{tf_env.inspect}")
    Logger.debug("tf_command: #{tf_command.inspect}")
    Logger.debug("tf_command_args: #{tf_command_args.inspect}")

    @tf_options      = tf_options
    @tf_env          = tf_env
    @tf_command      = tf_command
    @tf_command_args = tf_command_args

    Plugin::Loader.load_plugins
  end

  def run(env = {})
    Logger.debug('Building and running the stack')
    apply_action_hooks
    Logger.debug("actions: #{actions.inspect}")
    env.merge!(action_env)
    Logger.debug("env: #{env.inspect}")
    actions.call(env)
  end

  def actions
    @actions ||= build_action_stack
  end

  def build_action_stack
    command_data = Plugin.manager.commands[tf_command]
    command_proc = command_data[:proc]
    command_proc.call
  end

  def apply_action_hooks
    hooks = Plugin.manager.action_hooks
    Logger.debug("Applying #{hooks.length} action hooks")
    Plugin::ActionHook.new(actions).tap do |h|
      hooks.each { |hook_proc| hook_proc.call(h) }
    end
  end

  def action_env
    {
      tf_options:      tf_options,
      tf_env:          tf_env,
      tf_command:      tf_command,
      tf_command_args: tf_command_args,
      tfvars:          default_tfvars,
    }
  end

  def default_tfvars
    {
      'env' => tf_env,
    }
  end
end
