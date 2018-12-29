# frozen_string_literal: true

require 'yle_tf/config/migration'
require 'yle_tf/logger'

describe YleTf::Config::Migration do
  describe '.migrate_old_config' do
    before do
      # Silence the warnings
      allow(YleTf::Logger).to receive(:warn)
    end

    subject { described_class.migrate_old_config(config, opts) }
    let(:config) { { 'backend' => backend_config } }
    let(:opts) { { source: 'test' } }

    context 'with empty backend config' do
      let(:backend_config) { {} }
      it { is_expected.to eq('backend' => {}) }
    end

    context 'with new unknown backend config' do
      let(:backend_config) do
        {
          'type' => 'foo',
          'foo'  => {
            'bar' => 'baz'
          }
        }
      end

      it do
        is_expected.to eq(
          'backend' => {
            'type' => 'foo',
            'foo'  => {
              'bar' => 'baz'
            }
          }
        )
      end
    end

    context 'with new file backend config' do
      let(:backend_config) do
        {
          'type' => 'file',
          'file' => {
            'path' => 'some.tfstate'
          }
        }
      end

      it do
        is_expected.to eq(
          'backend' => {
            'type' => 'file',
            'file' => {
              'path' => 'some.tfstate'
            }
          }
        )
      end
    end

    context 'with new s3 backend config' do
      let(:backend_config) do
        {
          'type' => 's3',
          's3'   => {
            'region'  => 'us-east-1',
            'bucket'  => 'mybucket',
            'key'     => 'some.tfstate',
            'unknown' => 'option'
          }
        }
      end

      it do
        is_expected.to eq(
          'backend' => {
            'type' => 's3',
            's3'   => {
              'region'  => 'us-east-1',
              'bucket'  => 'mybucket',
              'key'     => 'some.tfstate',
              'unknown' => 'option'
            }
          }
        )
      end
    end

    context 'with new hybrid backend config ' do
      let(:backend_config) do
        {
          'type' => 's3',
          'file' => {
            'path' => 'some.tfstate'
          },
          's3'   => {
            'bucket' => 'mybucket',
            'key'    => 's3.tfstate'
          }
        }
      end

      it do
        is_expected.to eq(
          'backend' => {
            'type' => 's3',
            'file' => {
              'path' => 'some.tfstate'
            },
            's3'   => {
              'bucket' => 'mybucket',
              'key'    => 's3.tfstate'
            }
          }
        )
      end
    end

    context 'with old file backend config' do
      let(:backend_config) do
        {
          'type' => 'file',
          'file' => 'some.tfstate'
        }
      end

      it do
        is_expected.to eq(
          'backend' => {
            'type' => 'file',
            'file' => {
              'path' => 'some.tfstate'
            },
            's3'   => {
              'key' => 'some.tfstate'
            }
          }
        )
      end

      it 'warns' do
        expect(YleTf::Logger).to receive(:warn).with('Old configuration found in test')
        subject
      end
    end

    context 'with old hybrid backend config' do
      let(:backend_config) do
        {
          'type'   => 's3',
          'file'   => 'some.tfstate',
          'bucket' => 'mybucket',
          'region' => 'us-west-2',
          'foo'    => 'bar'
        }
      end

      it do
        is_expected.to eq(
          'backend' => {
            'type'   => 's3',
            'file'   => {
              'path' => 'some.tfstate'
            },
            's3'     => {
              'bucket' => 'mybucket',
              'key'    => 'some.tfstate',
              'region' => 'us-west-2'
            },
            'swift'  => {
              'region_name' => 'us-west-2'
            },
            'bucket' => 'mybucket',
            'region' => 'us-west-2',
            'foo'    => 'bar'
          }
        )
      end

      it 'warns' do
        expect(YleTf::Logger).to receive(:warn).with('Old configuration found in test')
        subject
      end

      it "doesn't change the original config" do
        expect(config).to eq(
          'backend' => {
            'type'   => 's3',
            'file'   => 'some.tfstate',
            'bucket' => 'mybucket',
            'region' => 'us-west-2',
            'foo'    => 'bar'
          }
        )
        subject
      end
    end
  end
end
