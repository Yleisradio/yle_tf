# frozen_string_literal: true

require 'rubygems'

class YleTf
  # Helper class for comparing versions
  class VersionRequirement
    # Checks if the specified Terrform version is older than 0.9
    def self.pre_0_9?(terraform_version)
      new('< 0.9.0-beta').satisfied_by?(terraform_version)
    end

    attr_reader :requirement

    def initialize(requirement)
      @requirement = requirement && Gem::Requirement.new(*requirement)
    end

    def satisfied_by?(version)
      !requirement || requirement.satisfied_by?(Gem::Version.new(version))
    end

    def to_s
      requirement.to_s
    end
  end
end
