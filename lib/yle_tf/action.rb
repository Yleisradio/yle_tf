class YleTf
  module Action
    autoload :Builder, 'yle_tf/action/builder'
    autoload :Command, 'yle_tf/action/command'
    autoload :CopyRootModule, 'yle_tf/action/copy_root_module'
    autoload :GenerateVarsFile, 'yle_tf/action/generate_vars_file'
    autoload :LoadConfig, 'yle_tf/action/load_config'
    autoload :TerraformInit, 'yle_tf/action/terraform_init'
    autoload :TfHooks, 'yle_tf/action/tf_hooks'
    autoload :TmpDir, 'yle_tf/action/tmpdir'
    autoload :VerifyTfEnv, 'yle_tf/action/verify_tf_env'
    autoload :VerifyTerraformVersion, 'yle_tf/action/verify_terraform_version'

    def self.default_action_stack(command_class = nil)
      Builder.new do
        use LoadConfig
        use VerifyTfEnv
        use TmpDir
        use VerifyTerraformVersion
        use CopyRootModule
        use GenerateVarsFile
        use TfHooks
        use TerraformInit

        use(Command, command_class) if command_class
      end
    end
  end
end
