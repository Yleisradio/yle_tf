# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'tmpdir'

require 'yle_tf/action/terraform_init'
require 'yle_tf/config'
require 'yle_tf/system'

describe YleTf::Action::TerraformInit do
  subject(:action) { described_class.new(app) }

  let(:app) { double('app', call: nil) }

  describe '#call' do
    let(:env) { { config: config } }
    let(:config) { instance_double('YleTf::Config') }

    let(:backend) { instance_double('YleTf::Backend') }

    let(:module_dir) { Pathname.new(module_dir_path) }
    let(:module_dir_path) { File.expand_path('../../fixtures/empty', __dir__) }

    let(:errored_tfstate) { Pathname.new('errored.tfstate') }

    before do
      allow(action).to receive(:backend) { backend }
      allow(backend).to receive(:configure) { nil }
      allow(config).to receive(:module_dir) { module_dir }

      allow(YleTf::System).to receive(:cmd)
      allow(YleTf::Logger).to receive(:info)

      # Run in a tmpdir as a symlink will be created
      @orig_pwd = Dir.pwd
      @tmpdir = Dir.mktmpdir
      Dir.chdir(@tmpdir)
    end

    after do
      # Remove the tmpdir
      Dir.chdir(@orig_pwd)
      FileUtils.rm_rf(@tmpdir, secure: true)
    end

    it 'does not raise' do
      expect { action.call(env) }.not_to raise_error
    end

    it 'calls next app' do
      expect(app).to receive(:call).with(env)
      action.call(env)
    end

    it 'configures the backend' do
      expect(backend).to receive(:configure)
      action.call(env)
    end

    it 'initializes Terraform' do
      expect(YleTf::System).to receive(:cmd).with('terraform', 'init', any_args)
      action.call(env)
    end

    it 'creates symlink to errored.tfstate' do
      action.call(env)
      expect(errored_tfstate).to be_symlink
      expect(errored_tfstate.readlink).to eq(module_dir.join('errored.tfstate'))
    end

    context 'when old errored.tfstate exists' do
      before do
        FileUtils.touch(errored_tfstate)
      end

      it 'replaces it with a symlink' do
        action.call(env)
        expect(errored_tfstate).to be_symlink
        expect(errored_tfstate.readlink).to eq(module_dir.join('errored.tfstate'))
      end
    end
  end
end
