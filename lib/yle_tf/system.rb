require 'shellwords'

require 'yle_tf/error'
require 'yle_tf/logger'

class YleTf
  # Helpers to execute system commands with error handling
  #
  # TODO: Add way to wrap stdout of the commands and direct it to `Logger`
  class System
    ExecuteError = Class.new(YleTf::Error)

    def self.cmd(*args, **opts)
      env = opts[:env]
      YleTf::Logger.debug { "Calling `#{args.shelljoin}`#{" with env '#{env}'" if env}" }

      system(env || {}, *args) ||
        raise(ExecuteError,
              "Failed to execute `#{args.shelljoin}`#{" with env '#{env}'" if env}")
    end
  end
end
