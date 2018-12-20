# frozen_string_literal: true

require 'optparse'

require 'yle_tf/system'
require 'yle_tf/plugin'

module YleTfPlugins
  module CommandHelp
    class Command
      def execute(env)
        device(env).puts(opts.help)
        exit 1 if error?(env)
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def opts
        OptionParser.new do |o|
          o.summary_width = 18
          o.banner = 'Usage: tf <environment> <command> [<args>]'
          o.separator ''
          o.separator 'YleTf options:'
          o.on('-h', '--help', 'Prints this help')
          o.on('-v', '--version', 'Prints the version information')
          o.on('--debug', 'Print debug information')
          o.on('--no-color', 'Do not output with colors')
          o.on('--no-hooks', 'Do not run any hooks')
          o.on('--only-hooks', 'Only run the hooks')
          o.separator ''
          o.separator 'Special tf commands:'
          o.separator tf_command_help
          o.separator ''
          o.separator 'Terraform commands:'
          o.separator terraform_help
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def error?(env)
        env[:tf_env] == 'error'
      end

      def device(env)
        error?(env) ? STDERR : STDOUT
      end

      def tf_command_help
        YleTf::Plugin.manager.commands.sort.map do |command, data|
          "    #{command.ljust(18)} #{data[:synopsis]}"
        end
      end

      def terraform_help
        on_error = proc do |exit_code|
          # exit_code is nil if the command was not found
          # Ignore other exit codes, as older Terraform versions return
          # non-zero exit codes for the help.
          return '    [Terraform not found]' if exit_code.nil?
        end
        help = YleTf::System.read_cmd('terraform', '--help', error_handler: on_error)
        help.lines.grep(/^    /)
      end
    end
  end
end
