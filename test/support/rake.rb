# frozen_string_literal: true

require 'rake'
require 'rspec/core/rake_task'
require 'rubygems'

require_relative 'env'

module TestSupport
  module Rake
    def self.terraform_versions(args, **opts)
      versions = args[:terraform_versions] || ENV['TERRAFORM_VERSIONS']
      versions&.split(/[, ]+/) || Array(opts[:default])
    end

    def self.run_tf(opts, &block)
      TfRunner.new(opts).run_tf(&block)
    end

    class TfRunner
      include TestSupport::Env
      include ::Rake::DSL

      attr_reader :opts

      def initialize(opts)
        @opts = opts
      end

      def run_tf(&block)
        module_dir    = opts[:module_dir]
        cleanup_globs = opts[:cleanup_globs]

        Dir.chdir(module_dir) do
          # Remove old generated files
          FileUtils.rm(Dir.glob(cleanup_globs)) if cleanup_globs

          with_env(environment) do
            sh(*command, &block)
          end
        end
      end

      def command
        ['tf', tf_env, tf_command, *tf_options]
      end

      def environment
        {
          'TERRAFORM_VERSION' => terraform_version,
          # Ensure that `TF_PLUGINS` is not set
          'TF_PLUGINS'        => nil,
          # Add helpers to PATH
          'PATH'              => "#{__dir__}/bin:#{ENV['PATH']}"
        }
      end

      def terraform_version
        opts[:terraform_version] || 'latest'
      end

      def tf_command
        opts[:tf_command]
      end

      def tf_env
        opts[:tf_env]
      end

      def tf_options
        tf_opts = %w[-input=false]
        tf_opts << '-auto-approve' if tf_command == 'apply' && terraform_0_10_or_newer?
        tf_opts + opts.fetch(:tf_options, [])
      end

      def terraform_0_10_or_newer?
        terraform_version == 'latest' ||
          Gem::Version.new(terraform_version) >= Gem::Version.new('0.10')
      end
    end
  end
end
