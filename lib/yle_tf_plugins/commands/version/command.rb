require 'optparse'

require 'yle_tf/version'

module YleTfPlugins
  module CommandVersion
    class Command
      def execute(_env)
        puts "YleTf #{YleTf::VERSION}"
        puts terraform_version
      end

      def terraform_version
        `terraform version`.lines.first
      rescue Errno::ENOENT
        '[Terraform not found]'
      end
    end
  end
end
