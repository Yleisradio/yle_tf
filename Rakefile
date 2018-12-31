# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

require_relative 'test/support/rake'

namespace :test do
  desc 'Run unit tests'
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = 'test/unit/**/*_spec.rb'
  end

  desc "Run acceptance tests\n" \
       "Terraform versions can be passed by a comma/space separated argument or \n" \
       'TERRAFORM_VERSIONS environment variable.'
  task :acceptance, [:terraform_versions] do |t, args|
    # Find all acceptance test tasks
    tasks = namespace(t.name) {}.tasks

    TestSupport::Rake.terraform_versions(args, default: 'latest').each do |v|
      rake_output_message "Running with Terraform version: #{v}"
      tasks.each do |task|
        # Force running the tasks multiple times (with different Terraform versions)
        task.reenable
        task.invoke(v)
      end
    end
  end

  namespace :acceptance do
    desc ''
    RSpec::Core::RakeTask.new(:spec, [:terraform_version]) do |t, args|
      t.pattern = 'test/acceptance/**/*_spec.rb'

      ENV['TERRAFORM_VERSION'] = args[:terraform_version]
    end

    task :example, [:terraform_version] do |_, args|
      TestSupport::Rake.run_tf(
        tf_command:        'apply',
        tf_env:            'test',
        tf_options:        ['--debug'],
        terraform_version: args[:terraform_version],
        module_dir:        'test/acceptance/fixtures/example',
        cleanup_globs:     %w[*.tfstate tf_example_test]
      )
    end
  end
end

desc 'Run all tests'
task :test, [:terraform_versions] => %w[test:unit test:acceptance]

task default: 'test:unit'
