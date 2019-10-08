# frozen_string_literal: true

require 'yle_tf/action/terraform_init'
require 'yle_tf/config'
require 'yle_tf/system'

describe YleTf::Action::TerraformInit do
  subject(:action) { described_class.new(app) }

  let(:app) { double('app', call: nil) }

  describe '#call' do
    let(:env) { { config: config } }
    let(:config) do
      YleTf::Config.new(
        'backend' => { 'type' => 'foo', 'foo' => {} }
      )
    end

    let(:backend) { instance_double('YleTf::Backend') }

    before do
      allow(action).to receive(:backend) { backend }
      allow(backend).to receive(:configure) { nil }

      allow(YleTf::System).to receive(:cmd)
      allow(YleTf::Logger).to receive(:info)
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
  end
end
