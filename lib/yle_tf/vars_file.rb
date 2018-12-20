# frozen_string_literal: true

class YleTf
  class VarsFile
    ENV_DIR = 'envs'

    # Returns the env specific tfvars file path if it exists
    def self.find_env_vars_file(config)
      path = "#{config.module_dir}/#{ENV_DIR}/#{config.tf_env}.tfvars"
      VarsFile.new(path) if File.exist?(path)
    end

    # Returns all envs that have tfvars files
    def self.list_all_envs(config)
      Dir.glob("#{config.module_dir}/#{ENV_DIR}/*.tfvars").sort.map do |path|
        File.basename(path, '.tfvars')
      end
    end

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def read
      IO.read(path)
    end

    def append_file(vars_file)
      File.open(path, 'a') do |file|
        file.puts # ensure we don't append to an existing line
        file.puts(vars_file.read)
      end
    end

    def eval_value(value)
      return %("#{value}") if value.is_a?(String)

      %({#{value.map { |k, v| %(#{k}="#{v}") }.join("\n")}})
    end

    def append_vars(vars)
      File.open(path, 'a') do |file|
        file.puts # ensure we don't append to an existing line
        vars.each do |key, value|
          file.puts %(#{key} = #{eval_value(value)})
        end
      end
    end
  end
end
