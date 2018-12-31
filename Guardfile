# frozen_string_literal: true

spec_dir = 'test/unit'

guard :rspec, cmd: 'bundle exec rspec --format progress', spec_paths: [spec_dir] do
  # RSpec files
  watch('test/spec_helper.rb') { spec_dir }
  watch(%r{^test/support/.+\.rb$}) { spec_dir }
  watch(%r{^#{spec_dir}/.+_spec\.rb$})
  watch(%r{^#{spec_dir}/fixtures/([^/]+)/}) { |m| "#{spec_dir}/#{m[1]}_spec.rb" }

  # Ruby files
  watch(%r{^lib/(.+)\.rb$}) { |m| "#{spec_dir}/#{m[1]}_spec.rb" }
  watch(%r{^vendor/.+\.rb$}) { spec_dir }
end
