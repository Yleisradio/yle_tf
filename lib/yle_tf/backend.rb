# frozen_string_literal: true

require 'json'

class YleTf
  class Backend
    BACKEND_CONFIG_FILE = '_backend.tf.json'

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def type
      @type ||= config.fetch('backend', 'type')
    end

    def backend_specific_config
      config.fetch('backend', type)
    end

    # Generate backend configuration file for Terraform
    def configure
      data = {
        terraform: [{
          backend: [to_h]
        }]
      }
      File.write(BACKEND_CONFIG_FILE, JSON.pretty_generate(data))
    end

    # Returns the backend configuration as a `Hash` for Terraform
    def to_h
      { type => backend_specific_config }
    end

    def to_s
      to_h.to_s
    end
  end
end
