# frozen_string_literal: true

require 'spec_helper'

require 'fileutils'
require 'ostruct'
require 'tempfile'
require 'yaml'
require 'yle_tf/vars_file'

describe YleTf::VarsFile do
  describe '.find_env_vars_file' do
    subject { described_class.find_env_vars_file(config) }
    let(:config) { OpenStruct.new(module_dir: module_dir, tf_env: tf_env) }
    let(:module_dir) { 'spec/fixtures/vars_files' }

    context 'with existing var file' do
      let(:tf_env) { 'diu' }
      it 'returns the corresponding tfvars file' do
        expect(subject.path).to eq("#{module_dir}/envs/#{tf_env}.tfvars")
      end
    end

    context 'with non-existing var file' do
      let(:tf_env) { 'foo' }
      it { is_expected.to be_nil }
    end
  end

  describe '.list_all_envs' do
    subject { described_class.list_all_envs(config) }
    let(:config) { OpenStruct.new(module_dir: module_dir) }

    context 'with existing var files' do
      let(:module_dir) { 'spec/fixtures/vars_files' }
      it { is_expected.to eq(%w[dau diu]) }
    end

    context 'with non-existing var files' do
      let(:module_dir) { 'non_existing_dir' }
      it { is_expected.to eq([]) }
    end
  end

  describe '#append_vars' do
    subject { described_class.new(path) }

    let(:path) { tempfile.path }
    let(:tempfile) do
      Tempfile.new(['yle_tf', '.tfvars']).tap do |f|
        f.close
        FileUtils.cp(original_tfvars, f.path)
      end
    end
    let(:original_tfvars) { 'spec/fixtures/vars_files/envs/dau.tfvars' }
    let(:appends_yaml) { 'spec/fixtures/vars_files/append_vars.append.yaml' }
    let(:final_tfvars) { 'spec/fixtures/vars_files/append_vars.final.tfvars' }

    it do
      subject.append_vars(YAML.safe_load(IO.read(appends_yaml)))
      expect(subject.read).to eq(IO.read(final_tfvars))
    end
  end
end
