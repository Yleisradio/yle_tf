# frozen_string_literal: true

require 'open3'
require 'yle_tf/error'
require 'yle_tf/tf_hook'

describe YleTf::TfHook do
  let(:dummy_io) { double.as_null_object }

  describe '.from_config' do
    subject(:hook) { described_class.from_config(conf, env) }
    let(:conf) do
      {
        'description' => description,
        'source'      => source,
        'vars'        => vars
      }
    end
    let(:description) { 'Hook description' }
    let(:source) { 'git@git.example.com:organization/repo.git//hook/path' }
    let(:vars) {} # defined for readability
    let(:env) { 'spec' }

    describe '#description' do
      subject { hook.description }
      it { is_expected.to eq(description) }
    end

    describe '#source' do
      subject { hook.source }
      it { is_expected.to eq(source) }
    end

    describe '#vars' do
      subject { hook.vars }

      context 'without vars' do
        let(:vars) { nil }
        it { is_expected.to eq({}) }
      end

      context 'with only default vars' do
        let(:vars) { { 'defaults' => { 'FOO' => 'bar', 'MEMORY' => '5TB' } } }
        it { is_expected.to eq(vars['defaults']) }
      end

      context 'with only env specific vars' do
        let(:vars) { { env => { 'DIU' => 'dau', 'MEMORY' => '2TB' } } }
        it { is_expected.to eq(vars[env]) }
      end

      context 'with default and env specific vars' do
        let(:vars) do
          {
            'defaults' => { 'FOO' => 'bar', 'MEMORY' => '5TB' },
            env        => { 'DIU' => 'dau', 'MEMORY' => '2TB' },
            'dummy'    => { 'FOO' => 'baz' }
          }
        end
        it 'returns the vars merged' do
          expect(subject).to eq('FOO' => 'bar', 'DIU' => 'dau', 'MEMORY' => '2TB')
        end
      end
    end

    describe '#run' do
      before do
        expect(Open3).to receive(:popen3)
          .with(expected_vars, expected_path)
          .and_yield(dummy_io, dummy_io, dummy_io, double(value: exit_status))
        allow(hook).to receive(:create_tmpdir) { tmpdir }
        expect(hook).to receive(:clone_git_repo)

        # silence the output
        allow($stdout).to receive(:write)
        allow($stderr).to receive(:write)
      end

      let(:exit_status) { double(success?: exit_code.zero?, exitstatus: exit_code) }
      let(:tf_vars) { { 'FOO' => 'xxx', 'BAR' => 'yyy' } }
      let(:expected_vars) { tf_vars }
      let(:expected_path) { "#{tmpdir}/hook/path" }
      let(:tmpdir) { '/tmp/dir' }

      context 'when the hook suceeds' do
        let(:exit_code) { 0 }

        it { expect { hook.run(tf_vars) }.not_to raise_error }

        context 'with configured vars' do
          let(:vars) do
            {
              'defaults' => { 'FOO' => 'bar', 'MEMORY' => '5TB' },
              env        => { 'DIU' => 'dau', 'MEMORY' => '2TB' }
            }
          end
          let(:expected_vars) do
            {
              'FOO' => 'xxx', 'BAR' => 'yyy',   # from tf_vars
              'DIU' => 'dau', 'MEMORY' => '2TB' # from merged config vars
            }
          end
          it 'merges all the vars' do
            hook.run(tf_vars)
          end
        end
      end

      context 'when the hook returns non-zero exit status' do
        let(:exit_code) { 1 }
        it { expect { hook.run(tf_vars) }.to raise_error(YleTf::System::ExecuteError) }
      end
    end
  end

  describe '.from_file' do
    subject(:hook) { described_class.from_file(path) }
    let(:path) { 'some/local/hook_file_name' }

    describe '#description' do
      subject { hook.description }
      it { is_expected.to eq('hook_file_name') }
    end

    describe '#path' do
      subject { hook.path }
      it { is_expected.to eq(path) }
    end

    describe '#vars' do
      subject { hook.vars }
      it { is_expected.to eq({}) }
    end

    describe '#run' do
      before do
        expect(Open3).to receive(:popen3)
          .with(tf_vars, path)
          .and_yield(dummy_io, dummy_io, dummy_io, double(value: exit_status))
        expect(hook).not_to receive(:clone_git_repo)

        # silence the output
        allow($stdout).to receive(:write)
        allow($stderr).to receive(:write)
      end

      let(:exit_status) { double(success?: exit_code.zero?, exitstatus: exit_code) }
      let(:tf_vars) { { 'FOO' => 'xxx', 'BAR' => 'yyy' } }

      context 'when the hook suceeds' do
        let(:exit_code) { 0 }
        it { expect { hook.run(tf_vars) }.not_to raise_error }
      end

      context 'when the hook returns non-zero exit status' do
        let(:exit_code) { 1 }
        it { expect { hook.run(tf_vars) }.to raise_error(YleTf::Error) }
      end
    end
  end
end
