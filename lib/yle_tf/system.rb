# frozen_string_literal: true

require 'English'
require 'open3'
require 'shellwords'
require 'stringio'
require 'thwait'
require 'yle_tf/error'
require 'yle_tf/logger'
require 'yle_tf/system/io_handlers'

class YleTf
  # Helpers to execute system commands with error handling
  class System
    ExecuteError = Class.new(YleTf::Error)

    DEFAULT_ERROR_HANDLER = ->(_exit_code, error) { raise error }.freeze

    DEFAULT_IO_HANDLERS = {
      stdin:  :dev_null,
      stdout: :info,
      stderr: :error
    }.freeze

    def self.console_cmd(*args, **opts)
      env = opts[:env] || {}

      YleTf::Logger.debug { "Calling #{cmd_string(args, env)}" }

      system(env, *args)
      verify_exit_status($CHILD_STATUS, opts[:error_handler], cmd_string(args))
    end

    # Executes the command and attaches IO streams
    def self.cmd(*args, **opts)
      opts = DEFAULT_IO_HANDLERS.merge(opts)
      env = opts[:env] || {}
      progname = opts.fetch(:progname) { args.first }

      YleTf::Logger.debug { "Calling #{cmd_string(args, env)}" }

      status = Open3.popen3(env, *args, &handle_io(progname, opts))
      verify_exit_status(status, opts[:error_handler], cmd_string(args))
    rescue Interrupt, Errno::ENOENT => e
      error(opts[:error_handler], "Failed to execute #{cmd_string(args)}: #{e}")
    end

    def self.read_cmd(*args, **opts)
      buffer = StringIO.new
      cmd(*args, opts.merge(stdout: buffer))
      buffer.string
    end

    def self.cmd_string(args, env = nil)
      "`#{args.shelljoin}`#{" with env '#{env}'" if env && !env.empty?}"
    end

    def self.handle_io(progname, handlers)
      lambda do |stdin, stdout, stderr, wait_thr|
        in_thr = attach_input_handler(handlers[:stdin], stdin, progname)
        out_thr = [
          attach_output_handler(handlers[:stdout], stdout, progname),
          attach_output_handler(handlers[:stderr], stderr, progname)
        ]

        # Wait for the process to exit
        wait_thr.value.tap do
          YleTf::Logger.debug("`#{progname}` exited, killing input handler thread")
          in_thr.kill if in_thr.is_a?(Thread)

          YleTf::Logger.debug('Waiting for output handler threads to stop')
          ThreadsWait.all_waits(out_thr)
        end
      end
    end

    def self.attach_input_handler(handler, io, progname)
      io_proc = IOHandlers.input_handler(handler)
      io_proc.call(io, progname)
    end

    def self.attach_output_handler(handler, io, progname)
      io_proc = IOHandlers.output_handler(handler)
      io_proc.call(io, progname)
    end

    def self.verify_exit_status(status, handler, cmd)
      status.success? ||
        error(handler,
              "Failed to execute #{cmd} (#{status.exitstatus})",
              status.exitstatus)
    end

    def self.error(handler, error_msg, exit_code = nil)
      YleTf::Logger.debug(error_msg)

      handler ||= DEFAULT_ERROR_HANDLER
      handler.call(exit_code, ExecuteError.new(error_msg))
    end
  end
end
