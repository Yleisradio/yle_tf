# frozen_string_literal: true

require 'spec_helper'

require 'ostruct'
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
end
