# frozen_string_literal: true

require 'fileutils'
require 'yle_tf/version'

context 'Without Terraform' do
  describe command('tf version') do
    before(:all) do
      ENV['SIMULATE_NONEXISTING_TERRAFORM'] = '1'

      # Ensure we have a .terraformrc to avoid INFO output
      @terraformrc = File.expand_path('~/.terraformrc')
      if File.exist?(@terraformrc)
        @terraformrc_orig = "#{@terraformrc}.orig"
        FileUtils.mv(@terraformrc, @terraformrc_orig)
      end
      FileUtils.cp("#{__dir__}/fixtures/terraformrc", @terraformrc)
    end

    after(:all) do
      ENV.delete('SIMULATE_NONEXISTING_TERRAFORM')

      if @terraformrc_orig
        FileUtils.mv(@terraformrc_orig, @terraformrc)
      else
        FileUtils.rm(@terraformrc)
      end
    end

    let(:yletf_version) { Regexp.escape(YleTf::VERSION) }

    its(:exit_status) { is_expected.to eq 0 }
    its(:stderr) { is_expected.to eq('') }
    its(:stdout) { is_expected.to match(/^YleTf #{yletf_version}$/) }
    its(:stdout) { is_expected.to match(/^\[Terraform not found\]$/) }
  end
end

context 'With Terraform' do
  describe command('tf version') do
    let(:yletf_version) { Regexp.escape(YleTf::VERSION) }
    let(:terraform_version) do
      v = ENV.fetch('TERRAFORM_VERSION', '')
      v = '' if v == 'latest'
      Regexp.escape(v)
    end

    its(:exit_status) { is_expected.to eq 0 }
    its(:stderr) { is_expected.to eq('') }
    its(:stdout) { is_expected.to match(/^YleTf #{yletf_version}$/) }
    its(:stdout) { is_expected.to match(/^Terraform v#{terraform_version}/) }
  end
end
