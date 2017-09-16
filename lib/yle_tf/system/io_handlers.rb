require 'yle_tf/system/output_logger'

class YleTf
  class System
    class IOHandlers
      BLOCK_SIZE = 1024

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      def self.input_handler(handler)
        case handler
        when :close
          close
        when :console
          console_input
        when :dev_null
          dev_null_input
        when IO, StringIO
          io_input(handler)
        else
          if !handler.respond_to?(:call)
            raise YleTf::Error, "Unknown input handler #{handler.inspect}"
          end
          handler
        end
      end

      def self.output_handler(handler)
        case handler
        when :close
          close
        when :console
          console_output
        when :dev_null
          dev_null_output
        when IO, StringIO
          io_output(handler)
        when Symbol
          OutputLogger.new(handler)
        else
          if !handler.respond_to?(:call)
            raise YleTf::Error, "Unknown output handler #{handler.inspect}"
          end
          handler
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

      # Returns a lambda that just closes the IO
      def self.close
        ->(io, *) { io.close }
      end

      # Returns a lambda that pipes STDIN to the IO
      def self.console_input
        io_input(STDIN)
      end

      # Returns a lambda that pipes IO's output to STDOUT
      def self.console_output
        io_output(STDOUT)
      end

      # Returns a lambda that does nothing
      def self.dev_null_input
        ->(*) {}
      end

      # Returns a lambda that just consumes the IO's output
      def self.dev_null_output
        lambda do |io, *|
          Thread.new do
            while io.read; end
          end
        end
      end

      # Returns a lambda that pipes the source IO to the IO's input
      def self.io_input(source)
        lambda do |target, *|
          Thread.new do
            begin
              while (data = source.readpartial(BLOCK_SIZE))
                target.write(data)
              end
            ensure
              target.close_write
            end
          end
        end
      end

      # Returns a lambda that pipes IO's output to the target IO
      # Does not close the target stream
      def self.io_output(target)
        lambda do |source, *|
          Thread.new do
            while (data = source.readpartial(BLOCK_SIZE))
              target.write(data)
            end
          end
        end
      end
    end
  end
end
