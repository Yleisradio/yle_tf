# frozen_string_literal: true

require 'yle_tf/action/tf_hooks'
require 'yle_tf/config'
require 'yle_tf/logger'

describe YleTf::Action::TfHooks do
  subject(:action) { described_class.new(app) }

  let(:app) { double('app', call: nil) }

  describe '#call' do
    let(:env) do
      { tf_command: tf_command, tf_env: tf_env, tf_options: tf_options, config: config }
    end

    let(:config) do
      YleTf::Config.new({}, tf_env: tf_env, module_dir: module_dir)
    end

    let(:tf_command) { 'mycommand' }
    let(:tf_env)     { 'myenv' }
    let(:tf_options) { {} }
    let(:module_dir) { '/foo/bar' }
    let(:no_hooks)   { nil }

    let(:hook_runner) { instance_double('YleTf::TfHook::Runner') }

    before do
      allow(YleTf::TfHook::Runner).to receive(:new) { hook_runner }
      allow(hook_runner).to receive(:run) { nil }
    end

    it 'runs pre and post hooks, and calls next app in-between' do
      expect(hook_runner).to receive(:run).with('pre').ordered
      expect(app).to receive(:call).with(env).ordered
      expect(hook_runner).to receive(:run).with('post').ordered

      action.call(env)
    end

    it 'initiates the runner with config' do
      expect(YleTf::TfHook::Runner).to receive(:new).with(config, anything) { hook_runner }

      action.call(env)
    end

    it 'initiates the runner with environment' do
      hook_env = {
        'TF_COMMAND'    => tf_command,
        'TF_ENV'        => tf_env,
        'TF_MODULE_DIR' => module_dir,
      }
      expect(YleTf::TfHook::Runner).to receive(:new).with(anything, hook_env) { hook_runner }

      action.call(env)
    end

    context 'with no-hooks option' do
      let(:tf_options) { { no_hooks: true } }

      it 'does not run hooks' do
        expect(YleTf::TfHook::Runner).not_to receive(:new)

        action.call(env)
      end

      it 'prints debug message' do
        expect(YleTf::Logger).to receive(:debug).with(/Skipping .* hooks/).twice

        action.call(env)
      end

      it 'calls next app' do
        expect(app).to receive(:call).with(env)

        action.call(env)
      end
    end
  end
end
