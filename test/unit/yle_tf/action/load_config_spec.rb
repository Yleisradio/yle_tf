# frozen_string_literal: true

require 'yle_tf/action/load_config'
require 'yle_tf/config'

describe YleTf::Action::LoadConfig do
  describe '#call' do
    before { allow(YleTf::Config).to receive(:load) }

    subject(:action) { described_class.new(app).call(env) }

    let(:app) { double('app', call: nil) }
    let(:env) { { tf_env: tf_env, config: config } }
    let(:tf_env) { 'myenv' }

    let(:dummy_config) { YleTf::Config.new('foo' => 'bar') }

    context 'when config not yet loaded' do
      let(:config) { nil }

      it 'loads the config' do
        expect(YleTf::Config).to receive(:load).with(tf_env) { dummy_config }
        action
      end

      it 'calls next app' do
        expect(app).to receive(:call).with(env)
        action
      end
    end

    context 'when already loaded' do
      let(:config) { dummy_config }

      it 'does not load the config again' do
        expect(YleTf::Config).not_to receive(:load)
        action
      end

      it 'calls next app' do
        expect(app).to receive(:call).with(env)
        action
      end
    end
  end
end
