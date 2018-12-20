# frozen_string_literal: true

require 'json'

class YleTf
  class BackendConfig
    BACKEND_CONFIG_FILE = '_backend.tf.json'

    attr_reader :type, :config

    def initialize(type, config)
      @type = type
      @config = config
    end

    # Returns an `Array` of CLI args for Terraform pre 0.9 `init` command
    def cli_args
      args = ["-backend=#{type}"]
      config.each do |key, value|
        args << "-backend-config=#{key}=#{value}"
      end
      args
    end

    # Generate backend configuration file for Terraform v0.9+
    def generate_config
      data = {
        terraform: [{
          backend: [to_h]
        }]
      }
      File.write(BACKEND_CONFIG_FILE, JSON.pretty_generate(data))
      yield if block_given?
    end

    # Returns the backend configuration as a `Hash` for Terraform v0.9+
    def to_h
      { type => config }
    end

    alias to_s to_h
  end
end
