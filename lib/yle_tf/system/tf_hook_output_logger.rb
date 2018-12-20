# frozen_string_literal: true

require 'yle_tf/logger'
require 'yle_tf/system/output_logger'

class YleTf
  class System
    # An IO handler class for YleTf Hook output.
    #
    # Allows hooks to emit log messages with specific levels
    # by prefixing a line with `<LEVEL>: `.
    class TfHookOutputLogger < OutputLogger
      def log(progname, line)
        # Remove `[<progname>] ` prefix from the output line.
        # This is mostly for backwards compatibility in Yle.
        line.sub!(/^\[#{progname}\] /, '')

        level, line = line_level(line)

        YleTf::Logger.public_send(level, progname) { line }
      end

      # Extracts the log level from the line if found,
      # otherwise returns the default level and the line as is
      def line_level(line)
        if (m = /^(?<level>[A-Z]+): (?<line>.*)$/.match(line))
          line_level = m[:level].downcase.to_sym
          return [line_level, m[:line]] if level?(line_level)
        end

        [level, line]
      end
    end
  end
end
