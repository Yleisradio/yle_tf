# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

require 'yle_tf/error'
require 'yle_tf/logger'
require 'yle_tf/system'
require 'yle_tf/system/tf_hook_output_logger'

class YleTf
  class TfHook
    autoload :Runner, 'yle_tf/tf_hook/runner'

    # Returns a `TfHook` instance from configuration hash
    def self.from_config(config, tf_env)
      TfHook.new(
        description: config['description'],
        source:      config['source'],
        vars:        merge_vars(config['vars'], tf_env)
      )
    end

    # Returns a `Hook` instance from a local file path
    def self.from_file(path)
      TfHook.new(
        description: File.basename(path),
        path:        path
      )
    end

    attr_reader :description, :source, :path, :vars

    def initialize(opts = {})
      @description = opts[:description]
      @source = opts[:source]
      @path = opts[:path]
      @vars = opts[:vars] || {}
      @tmpdir = nil
    end

    def run(tf_vars)
      fetch if !path

      Logger.info("Running hook '#{description}'")
      YleTf::System.cmd(
        path,
        env:      vars.merge(tf_vars),
        progname: File.basename(path),
        stdout:   System::TfHookOutputLogger.new(:info),
        stderr:   System::TfHookOutputLogger.new(:error)
      )
    ensure
      delete_tmpdir
    end

    def parse_source_config
      m = %r{^(?<uri>.+)//(?<path>[^?]+)(\?ref=(?<ref>.*))?$}.match(source)
      raise Error, "Invalid or missing `source` for hook '#{description}'" if !m

      {
        uri:  m[:uri],
        path: m[:path],
        ref:  m[:ref] || 'master'
      }
    end

    def fetch
      source_config = parse_source_config
      source_config[:dir] = create_tmpdir
      clone_git_repo(source_config)
      @path = File.join(source_config[:dir], source_config[:path])
    end

    def clone_git_repo(config)
      Logger.debug("Cloning hook '#{description}' from #{config[:uri]} (#{config[:ref]})")
      YleTf::System.cmd(
        'git', 'clone', '--quiet', '--depth=1', '--branch', config[:ref],
        '--', config[:uri], config[:dir]
      )
    end

    def create_tmpdir
      @tmpdir = Dir.mktmpdir('tf_hook_')
    end

    def delete_tmpdir
      FileUtils.rm_r(@tmpdir) if @tmpdir && Dir.exist?(@tmpdir)
      @tmpdir = nil
    end

    # Returns a hash with env specific vars merged into the default ones
    def self.merge_vars(vars, tf_env)
      vars ||= {}
      defaults = vars['defaults'] || {}
      defaults.merge(vars[tf_env] || {})
    end
  end
end
