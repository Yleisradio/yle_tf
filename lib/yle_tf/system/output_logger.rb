require 'yle_tf/logger'

class YleTf
  class System
    class OutputLogger
      attr_reader :level

      def initialize(level)
        @level = level.to_sym

        raise YleTf::Error, "Unknown log level '#{@level}'" if !level?(@level)
      end

      def call(io, progname)
        Thread.new do
          io.each { |line| log(progname, line.chomp) }
        end
      end

      def level?(level)
        YleTf::Logger::LEVELS.include?(level)
      end

      def log(progname, line)
        YleTf::Logger.public_send(level, progname) { line }
      end
    end
  end
end
