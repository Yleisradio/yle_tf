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

    let(:terraform_lock) { Pathname.new('.terraform.lock.hcl') }
    let(:errored_tfstate) { Pathname.new('errored.tfstate') }

    before do
      allow(action).to receive(:backend) { backend }
      allow(backend).to receive(:configure) { nil }
      allow(config).to receive(:module_dir) { module_dir }

      allow(YleTf::System).to receive(:cmd)
      allow(YleTf::Logger).to receive(:info)
      allow(FileUtils).to receive(:cp)

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

    context 'when TF_INIT_ARGS is set' do
      before do
        ENV['TF_INIT_ARGS'] = '-force-copy -upgrade'
      end

      it 'passes them to Terraform' do
        expect(YleTf::System).to receive(:cmd) do |*args|
          expect(args.shift).to eq('terraform')
          expect(args.shift).to eq('init')
          expect(args).to include('-force-copy')
          expect(args).to include('-upgrade')
        end
        action.call(env)
      end
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

    context 'when .terraform.lock.hcl does not exist' do
      it 'copies it back to module dir' do
        expect(FileUtils).not_to receive(:cp)
        action.call(env)
      end
    end

    context 'when .terraform.lock.hcl exists' do
      it 'copies it back to module dir' do
        expect(YleTf::System).to receive(:cmd).with('terraform', 'init', any_args) do
          FileUtils.touch(terraform_lock)
        end
        expect(FileUtils).to receive(:cp).with(terraform_lock.to_s, module_dir.to_s)
        action.call(env)
      end
    end

    context 'when tf_command is "init"' do
      before do
        env[:tf_command] = 'init'
      end

      it 'does not call `terraform init` directly' do
        expect(YleTf::System).not_to receive(:cmd).with('terraform', 'init', any_args)
        action.call(env)
      end

      it 'copies .terraform.lock.hcl back to module dir after calling next app' do
        expect(app).to receive(:call).with(env).ordered do
          FileUtils.touch(terraform_lock)
        end
        expect(FileUtils).to receive(:cp).with(terraform_lock.to_s, module_dir.to_s).ordered
        action.call(env)
      end
    end
  end
end
