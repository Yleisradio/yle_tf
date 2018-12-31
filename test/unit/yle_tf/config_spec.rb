# frozen_string_literal: true

require 'yle_tf/config'
require 'yle_tf/logger'

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
    subject(:fetch) { config.fetch(*keys, &block) }

    let(:block) { nil }
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

    context 'when the key is not found' do
      before { allow(YleTf::Logger).to receive(:warn) }

      context 'with default block' do
        let(:keys) { %w[nonexisting] }

        it { expect { fetch }.to raise_error(YleTf::Config::NotFoundError) }

        context 'with nonexisting key' do
          let(:keys) { %w[some non_existing] }

          it 'does not warn' do
            expect(YleTf::Logger).not_to receive(:warn)
            begin fetch; rescue YleTf::Error; end # rubocop:disable Lint/HandleExceptions
          end
        end

        context 'with broken key chain' do
          let(:keys) { %w[foo non_existing] }

          it 'warns' do
            expect(YleTf::Logger).to receive(:warn)
            begin fetch; rescue YleTf::Error; end # rubocop:disable Lint/HandleExceptions
          end
        end
      end

      context 'with specified block' do
        let(:keys) { %w[some thing missing] }
        let(:block) { ->(_keys) { 'my_default_value' } }

        it { is_expected.to eq('my_default_value') }

        it 'calls the block' do
          expect(block).to receive(:call).with(%w[some thing missing])
          fetch
        end

        context 'with nonexisting key' do
          it 'does not warn' do
            expect(YleTf::Logger).not_to receive(:warn)
            fetch
          end
        end

        context 'with broken key chain' do
          let(:keys) { %w[foo non_existing] }

          it 'warns' do
            expect(YleTf::Logger).to receive(:warn)
            fetch
          end
        end
      end
    end
  end
end
