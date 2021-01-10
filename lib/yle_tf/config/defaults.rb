# frozen_string_literal: true

require 'yle_tf/helpers/hash'

class YleTf
  class Config
    module Defaults
      DEFAULT_CONFIG = {
        'hooks'     => {
          'pre'  => [],
          'post' => []
        },
        'backend'   => {
          'type' => 'file',
          'file' => {
            'path'            => '<%= @module %>_<%= @env %>.tfstate',
            'encrypt'         => false,
            'encrypt_command' => 'sops --encrypt --input-type binary --output-type binary --output "{{TO}}" "{{FROM}}"',
            'decrypt_command' => 'sops --decrypt --input-type binary --output-type binary --output "{{TO}}" "{{FROM}}"'
          },
          's3'   => {
            'key' => '<%= @module %>_<%= @env %>.tfstate'
          }
        },
        'tfvars'    => {
        },
        'terraform' => {
          'version_requirement' => nil
        },
        'yle_tf'    => {
          'version_requirement' => nil
        }
      }.freeze

      # Returns deep copy of the default config Hash.
      def default_config
        Helpers::Hash.deep_copy(DEFAULT_CONFIG)
      end

      def default_config_context
        {
          env:        tf_env,
          module:     module_dir.basename.to_s,
          module_dir: module_dir.to_s,
        }
      end
    end
  end
end
