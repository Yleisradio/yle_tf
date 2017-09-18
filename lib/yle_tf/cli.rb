require 'yle_tf'

class YleTf
  class CLI
    attr_reader :tf_options, :tf_command, :tf_command_args, :tf_env

    # YleTf option arguments
    TF_OPTIONS = %w[--debug --no-color --no-hooks --only-hooks].freeze

    HELP_ARGS = %w[-h --help help].freeze
    VERSION_ARGS = %w[-v --version version].freeze

    def initialize(argv)
      @tf_options = {}
      @tf_command_args = []
      split_args(argv)
    end

    def execute
      tf = YleTf.new(tf_options, tf_env, tf_command, tf_command_args)
      tf.run
    rescue YleTf::Error => e
      raise e if debug?

      Logger.fatal e
      exit 1
    end

    # rubocop:disable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def split_args(argv)
      argv.each do |arg|
        if @tf_env && @tf_command
          if TF_OPTIONS.include?(arg)
            @tf_options[key(arg)] = true
          else
            @tf_command_args << arg
          end
        elsif HELP_ARGS.include?(arg)
          @tf_command = 'help'
          @tf_env = '_'
          break
        elsif VERSION_ARGS.include?(arg)
          @tf_command = 'version'
          @tf_env = '_'
          break
        elsif arg.start_with?('-')
          if TF_OPTIONS.include?(arg)
            @tf_options[key(arg)] = true
          else
            STDERR.puts "Unknown option '#{arg}'"
            @tf_command = 'help'
            @tf_env = 'error'
            break
          end
        elsif !@tf_env
          @tf_env = arg
        else
          @tf_command = arg
        end
      end

      if !@tf_command || !@tf_env
        @tf_command = 'help'
        @tf_env = 'error'
      end

      self.debug = true if @tf_options[:debug]
      YleTf::Logger.color = !@tf_options[:no_color]
    end

    # Returns `Symbol` for the arg, e.g. `"--foo-bar"` -> `:foo_bar`
    def key(arg)
      arg.sub(/\A--?/, '').tr('-', '_').to_sym
    end

    def debug=(value)
      if value
        ENV['TF_DEBUG'] = '1'
      else
        ENV.delete('TF_DEBUG')
      end
    end

    def debug?
      ENV.key?('TF_DEBUG')
    end
  end
end
