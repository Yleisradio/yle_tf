# frozen_string_literal: true

require 'yle_tf/action/verify_yle_tf_version'
require 'yle_tf/config'
require 'yle_tf/error'

describe YleTf::Action::VerifyYleTfVersion do
  subject(:action) { described_class.new(app) }

  let(:app) { double('app', call: nil) }

  describe '#call' do
    let(:env) { { config: config } }
    let(:config) do
      YleTf::Config.new(
        {
          'yle_tf' => { 'version_requirement' => version_requirement }
        }
      )
    end

    let(:version) { '1.2.3' }

    before do
      stub_const('YleTf::VERSION', version)
    end

    context 'without configuration' do
      let(:version_requirement) { nil }

      it 'does not raise' do
        expect { action.call(env) }.not_to raise_error
      end

      it 'calls next app' do
        expect(app).to receive(:call).with(env)
        action.call(env)
      end
    end

    context 'with configuration' do
      context 'with accepted version' do
        let(:version_requirement) { '>= 1.1' }

        it 'does not raise' do
          expect { action.call(env) }.not_to raise_error
        end

        it 'calls next app' do
          expect(app).to receive(:call).with(env)
          action.call(env)
        end
      end

      context 'with wrong version' do
        let(:version_requirement) { '~> 1.0.4' }

        it 'raises an error' do
          expect(app).not_to receive(:call).with(env)

          expect { action.call(env) }.to raise_error(
            YleTf::Error, "YleTf version '1.2.3', '~> 1.0.4' required by config"
          )
        end
      end
    end
  end
end
