# frozen_string_literal: true

require 'yaml'
require 'yle_tf/helpers/hash'
require 'yle_tf/logger'

class YleTf
  class Config
    class Migration
      BACKEND_MIGRATIONS = {
        'file'  => {
          'file' => 'path'
        },
        's3'    => {
          'region'  => 'region',
          'bucket'  => 'bucket',
          'file'    => 'key',
          'encrypt' => 'encrypt'
        },
        'swift' => {
          'region'            => 'region_name',
          'container'         => 'container',
          'archive_container' => 'archive_container'
        }
      }.freeze

      include Helpers::Hash

      def self.migrate_old_config(config, **opts)
        new(config, **opts).migrated_config
      end

      attr_reader :config, :config_source

      def initialize(config, **opts)
        @config = config
        @config_source = opts.fetch(:source)
      end

      def old_backend_config
        config['backend']
      end

      def migrated_config
        migrate_old_backend_config(&deprecation_warning)
      end

      # Returns a `Proc` to print deprecation warnings unless denied by an env var
      def deprecation_warning
        return nil if ENV['TF_OLD_CONFIG_WARNINGS'] == 'false'

        ->(new_config) do
          Logger.warn("Old configuration found in #{config_source}")
          Logger.warn("Please migrate to relevant parts of:\n" \
                      "#{sanitize_config(new_config)}")
          Logger.warn(
            'See https://github.com/Yleisradio/yle_tf/wiki/Migrating-Configuration for more details'
          )
        end
      end

      # TODO: Remove support in v2.0
      def migrate_old_backend_config
        changed = false

        new_config = BACKEND_MIGRATIONS.inject(config) do |prev_config, (type, keys)|
          migrate_old_backend_config_keys(prev_config, type, keys) { changed = true }
        end

        yield(new_config) if changed && block_given?

        new_config
      end

      def migrate_old_backend_config_keys(config, type, keys)
        migrated_keys = find_old_backend_config_keys(keys)
        return config if migrated_keys.empty?

        defaults = {
          'backend' => {
            type => {}
          }
        }
        copy_with_defaults(config, defaults).tap do |new_config|
          migrated_keys.each do |old_key, new_key|
            new_config['backend'][type][new_key] = old_backend_config[old_key]
          end

          yield new_config
        end
      end

      def find_old_backend_config_keys(keys)
        return {} if !old_backend_config.is_a?(Hash)

        keys.select do |old_key, _new_key|
          old_backend_config.key?(old_key) &&
            # Special case for 'file' as it is now used for option Hash for the
            # 'file' backend
            !(old_key == 'file' && old_backend_config['file'].is_a?(Hash))
        end
      end

      def copy_with_defaults(config, defaults)
        deep_merge(deep_copy(config), defaults)
      end

      def sanitize_config(config)
        backend_config = config['backend'].select do |key, value|
          key == 'type' || value.is_a?(Hash)
        end

        YAML.dump('backend' => backend_config)
      end
    end
  end
end
