# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

namespace :test do
  desc 'Run unit tests'
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = 'test/unit/**/*_spec.rb'
  end
end

task default: 'test:unit'
