require 'logger'

class YleTf
  module LoggerLevelPatch
    # Taken from Ruby 2.4.1
    def level=(severity)
      if severity.is_a?(Integer)
        @level = severity
      else
        case severity.to_s.downcase
        when 'debug'.freeze
          @level = ::Logger::DEBUG
        when 'info'.freeze
          @level = ::Logger::INFO
        when 'warn'.freeze
          @level = ::Logger::WARN
        when 'error'.freeze
          @level = ::Logger::ERROR
        when 'fatal'.freeze
          @level = ::Logger::FATAL
        when 'unknown'.freeze
          @level = ::Logger::UNKNOWN
        else
          raise ArgumentError, "invalid log level: #{severity}"
        end
      end
    end
  end
end
