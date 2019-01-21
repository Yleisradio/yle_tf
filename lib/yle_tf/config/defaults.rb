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
            'path' => '<%= @module %>_<%= @env %>.tfstate'
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
