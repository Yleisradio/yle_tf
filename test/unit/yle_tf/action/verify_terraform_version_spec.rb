# frozen_string_literal: true

require 'yle_tf/action/verify_terraform_version'
require 'yle_tf/config'
require 'yle_tf/error'

describe YleTf::Action::VerifyTerraformVersion do
  subject(:action) { described_class.new(app) }

  let(:app) { double('app', call: nil) }

  describe '#call' do
    before do
      stub_const('YleTf::TERRAFORM_VERSION_REQUIREMENT', '>= 1.1')
      allow(action).to receive(:terraform_version) { terraform_version }
    end

    subject(:call) { action.call(env) }

    let(:env) { { config: config } }
    let(:config) do
      YleTf::Config.new('terraform' => {
                          'version_requirement' => config_requirement
                        })
    end
    let(:config_requirement) { nil }

    context 'when Terraform not found' do
      let(:terraform_version) { nil }

      it { expect { call }.to raise_error(YleTf::Error, 'Terraform not found') }
    end

    context 'without configuration' do
      let(:config_requirement) { nil }

      context 'with supported Terraform version' do
        let(:terraform_version) { '1.2.3' }

        it 'stores the version to env' do
          call
          expect(env[:terraform_version]).to eq('1.2.3')
        end

        it 'calls next app' do
          expect(app).to receive(:call).with(env)
          call
        end
      end

      context 'with unsupported Terraform version' do
        let(:terraform_version) { '0.11.11' }

        it do
          expect { call }.to raise_error(
            YleTf::Error, "Terraform version '>= 1.1' required by YleTf, '0.11.11' found"
          )
        end
      end
    end

    context 'with configuration' do
      let(:config_requirement) { '~> 1.3.7' }

      context 'with supported Terraform version' do
        context 'when accepted by config' do
          let(:terraform_version) { '1.3.12' }

          it 'stores the version to env' do
            call
            expect(env[:terraform_version]).to eq('1.3.12')
          end

          it 'calls next app' do
            expect(app).to receive(:call).with(env)
            call
          end
        end

        context 'when denied by config' do
          let(:terraform_version) { '1.5.0' }
          it do
            expect { call }.to raise_error(
              YleTf::Error, "Terraform version '~> 1.3.7' required by config, '1.5.0' found"
            )
          end
        end
      end

      context 'with unsupported Terraform version' do
        let(:terraform_version) { '0.11.11' }

        it do
          expect { call }.to raise_error(
            YleTf::Error, "Terraform version '>= 1.1' required by YleTf, '0.11.11' found"
          )
        end
      end
    end
  end
end
