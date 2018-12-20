# frozen_string_literal: true

class YleTf
  class Config
    module Defaults
      DEFAULT_CONFIG = {
        'hooks'     => {
          'pre'  => [],
          'post' => []
        },
        'backend'   => {
          'type'    => 'file',
          'bucket'  => nil,
          'file'    => '<%= @module %>_<%= @env %>.tfstate',
          'region'  => nil,
          'encrypt' => false,
        },
        'tfvars'    => {
        },
        'terraform' => {
          'version_requirement' => nil
        }
      }.freeze

      def default_config
        DEFAULT_CONFIG.dup
      end

      def default_config_context
        {
          env:    tf_env,
          module: module_dir.basename.to_s,
        }
      end
    end
  end
end
