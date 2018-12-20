# frozen_string_literal: true

module YleTfPlugins
  module CommandShell
    class Command
      def execute(_env)
        shell = ENV.fetch('SHELL', 'bash')

        puts "Executing shell '#{shell}' in the Terraform directory"
        puts 'Use `exit` to quit'
        puts

        system(shell)
      end
    end
  end
end
