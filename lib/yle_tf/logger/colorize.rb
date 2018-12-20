# frozen_string_literal: true

class YleTf
  module Logger
    module Colorize
      COLORS = {
        black:   30,
        red:     31,
        brown:   33,
        blue:    34,
        magenta: 35,
        cyan:    36,
        gray:    37
      }.freeze

      # Wraps the message with the specified ANSI color code
      # if the color is specified and supported
      def self.colorize(msg, color)
        code = COLORS[color]
        code ? "\033[#{code}m#{msg}\033[0m" : msg
      end
    end
  end
end
