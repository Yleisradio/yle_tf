require 'yaml'

require 'yle_tf/logger'

class YleTf
  class Config
    class File
      attr_reader :name

      def initialize(name)
        @name = name.to_s
      end

      def read
        YAML.load_file(name) || {}
      rescue StandardError => e
        Logger.fatal("Failed to load or parse configuration from '#{name}'")
        raise e
      end

      def to_s
        name
      end
    end
  end
end
