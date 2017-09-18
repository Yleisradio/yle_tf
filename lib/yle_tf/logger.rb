require 'forwardable'
require 'logger'
require 'rubygems'
require 'yle_tf/logger/colorize'

class YleTf
  # Logger for debug, error, etc. outputs.
  # Prints to STDERR, so it does not mess with e.g. `terraform output`.
  module Logger
    LEVELS = %i[debug info warn error fatal].freeze

    class << self
      extend Forwardable
      def_delegators :logger, *LEVELS
      def_delegators :logger, :debug?
    end

    def self.logger
      @logger ||= ::Logger.new(STDERR).tap do |logger|
        patch_for_old_ruby(logger)
        logger.level = log_level
        logger.formatter = log_formatter
      end
    end

    def self.log_level
      (ENV['TF_DEBUG'] && 'DEBUG') || \
        ENV['TF_LOG'] || \
        'INFO'
    end

    def self.log_formatter
      proc do |severity, _datetime, progname, msg|
        msg = Colorize.colorize(msg, color(severity))

        if progname
          "#{severity}: [#{progname}] #{msg}\n"
        else
          "#{severity}: #{msg}\n"
        end
      end
    end

    def self.color?
      @color
    end

    def self.color=(value)
      @color = value
    end

    def self.color(severity)
      return if !color?

      case severity.to_s
      when 'FATAL', 'ERROR'
        :red
      when 'WARN'
        :brown
      end
    end

    # Patches the `::Logger` in older Ruby versions to
    # accept log level as a `String`
    def self.patch_for_old_ruby(logger)
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.3')
        require_relative '../../vendor/logger_level_patch'
        logger.extend(LoggerLevelPatch)
      end
    end
  end
end
