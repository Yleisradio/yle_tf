# frozen_string_literal: true

require 'yle_tf/error'
require 'yle_tf/logger'
require 'yle_tf/version'
require 'yle_tf/version_requirement'

class YleTf
  module Action
    class VerifyYleTfVersion
      def initialize(app)
        @app = app
      end

      def call(env)
        Logger.debug('Verifying YleTf version')

        requirement = requirement(env[:config])
        verify_version(requirement)

        @app.call(env)
      end

      def requirement(config)
        requirement = config.fetch('yle_tf', 'version_requirement') { nil }
        VersionRequirement.new(requirement)
      end

      def verify_version(requirement)
        return if requirement.satisfied_by?(YleTf::VERSION)

        raise Error, "YleTf version '#{YleTf::VERSION}', '#{requirement}' required by config"
      end
    end
  end
end
