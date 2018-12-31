# frozen_string_literal: true

require 'yle_tf/config'

describe YleTf::Config do
  subject(:config) { described_class.new(config_hash, opts) }
  let(:config_hash) { {} }
  let(:opts) { {} }

  describe '#config' do
    subject { config.config }
    let(:config_hash) { { 'foo' => 'bar' } }

    it { is_expected.to eq('foo' => 'bar') }
  end

  describe '#tf_env' do
    subject { config.tf_env }
    let(:opts) { { tf_env: 'myenv' } }

    it { is_expected.to eq('myenv') }
  end

  describe '#module_dir' do
    subject { config.module_dir }
    let(:opts) { { module_dir: '/foo/bar' } }

    it { is_expected.to eq('/foo/bar') }
  end

  describe '#fetch' do
    let(:config_hash) do
      {
        'foo'  => 'bar',
        'some' => {
          'deep'      => {
            'thing' => 99
          },
          'nil_value' => nil
        }
      }
    end

    it 'returns first level keys' do
      expect(config.fetch('foo')).to eq('bar')
    end

    it 'returns hierarchial keys' do
      expect(config.fetch('some', 'deep', 'thing')).to eq(99)
    end

    it 'returns nil values' do
      expect(config.fetch('some', 'nil_value')).to be_nil
    end

    it 'returns hashes' do
      expect(config.fetch('some', 'deep')).to eq('thing' => 99)
    end

    context 'with default block' do
      it { expect { config.fetch('non_existing') }.to raise_error(YleTf::Config::NotFoundError) }
    end

    context 'with specified block' do
      let(:subject) { config.fetch('foo', 'bar', &block) }
      let(:block) { ->(_keys) { 'my_default_value' } }

      it { is_expected.to eq('my_default_value') }

      it 'calls the block' do
        expect(block).to receive(:call).with(%w[foo bar])
        subject
      end
    end
  end
end
