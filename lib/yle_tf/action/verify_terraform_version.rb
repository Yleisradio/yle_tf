# frozen_string_literal: true

require 'yle_tf/error'
require 'yle_tf/logger'
require 'yle_tf/system'
require 'yle_tf/version_requirement'

class YleTf
  module Action
    class VerifyTerraformVersion
      def initialize(app)
        @app = app
      end

      def call(env)
        Logger.debug('Verifying Terraform version')

        version = env[:terraform_version] = terraform_version
        raise(Error, 'Terraform not found') if !version

        Logger.debug("Terraform version: #{version}")
        verify_version(env)

        @app.call(env)
      end

      def terraform_version
        v = YleTf::System.read_cmd('terraform', 'version', error_handler: proc {})
        Regexp.last_match(1) if v =~ /^Terraform v([^\s]+)/
      end

      def verify_version(env)
        version = env[:terraform_version]
        requirement = env[:config].fetch('terraform', 'version_requirement') { nil }

        if !VersionRequirement.new(requirement).satisfied_by?(version)
          raise Error, "Terraform version '#{requirement}' required, '#{version}' found"
        end
      end
    end
  end
end
