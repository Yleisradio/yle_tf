# frozen_string_literal: true

require 'pathname'
require 'yle_tf/config/loader'

describe YleTf::Config::Loader do
  describe '#load' do
    before do
      allow(loader).to receive(:plugins) { [] }
    end

    subject { loader.load }

    let(:loader) { described_class.new(tf_env: tf_env, module_dir: module_dir) }
    let(:tf_env) { 'unit-tests' }
    let(:module_dir) { Pathname.new(module_dir_path) }
    let(:module_dir_path) { '/hopefully/non-existing/test-module' }

    context 'with default config' do
      it do
        is_expected.to eq(
          'backend'   => {
            'type' => 'file',
            'file' => { 'path' => 'test-module_unit-tests.tfstate' },
            's3'   => { 'key' => 'test-module_unit-tests.tfstate' }
          },
          'hooks'     => { 'pre' => [], 'post' => [] },
          'tfvars'    => {},
          'terraform' => { 'version_requirement' => nil }
        )
      end
    end

    context 'with plugin and file configs' do
      let(:test_plugin) do
        double('TestPlugin',
               default_config: {
                 'backend' => { 'foo' => { 'bar' => 'from_plugin' } },
                 'tfvars'  => { 'xxx' => 'yyy' }
               })
      end

      let(:config_file) do
        double('config file',
               name: '/hopefully/tf.yaml',
               read: {
                 'backend' => {
                   'type' => 'foo',
                   'foo'  => { 'bar' => 'from_file' }
                 }
               })
      end

      it 'merges the configurations' do
        expect(loader).to receive(:plugins) { [test_plugin] }
        expect(loader).to receive(:config_files) { [config_file] }

        is_expected.to eq(
          'backend'   => {
            'type' => 'foo',
            'file' => { 'path' => 'test-module_unit-tests.tfstate' },
            's3'   => { 'key' => 'test-module_unit-tests.tfstate' },
            'foo'  => { 'bar' => 'from_file' }
          },
          'hooks'     => { 'pre' => [], 'post' => [] },
          'tfvars'    => { 'xxx' => 'yyy' },
          'terraform' => { 'version_requirement' => nil }
        )
      end
    end
  end
end
