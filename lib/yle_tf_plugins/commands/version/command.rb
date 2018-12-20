# frozen_string_literal: true

require 'yle_tf/system'
require 'yle_tf/version'

module YleTfPlugins
  module CommandVersion
    class Command
      def execute(_env)
        puts "YleTf #{YleTf::VERSION}"
        puts terraform_version
      end

      def terraform_version
        on_error = proc { return '[Terraform not found]' }
        v = YleTf::System.read_cmd('terraform', 'version', error_handler: on_error)
        v.lines.first
      end
    end
  end
end
