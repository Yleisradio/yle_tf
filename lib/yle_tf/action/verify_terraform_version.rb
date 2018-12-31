# frozen_string_literal: true

require 'yle_tf'
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

        verify_version(version, requirement_by_yletf, required_by: 'YleTf')
        verify_version(version, requirement_by_config(env), required_by: 'config')

        @app.call(env)
      end

      def terraform_version
        v = YleTf::System.read_cmd('terraform', 'version', error_handler: proc {})
        m = /^Terraform v(?<version>[^\s]+)/.match(v)
        m && m[:version]
      end

      def requirement_by_config(env)
        requirement = env[:config].fetch('terraform', 'version_requirement') { nil }
        VersionRequirement.new(requirement)
      end

      def requirement_by_yletf
        VersionRequirement.new(YleTf::TERRAFORM_VERSION_REQUIREMENT)
      end

      def verify_version(version, requirement, **opts)
        if !requirement.satisfied_by?(version)
          raise Error, "Terraform version '#{requirement}' required by #{opts[:required_by]}, " \
                       "'#{version}' found"
        end
      end
    end
  end
end
