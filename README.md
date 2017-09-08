# YleTf

[![Gem Version](https://badge.fury.io/rb/yle_tf.svg)](https://badge.fury.io/rb/yle_tf)
[![Build Status](https://travis-ci.org/Yleisradio/yle_tf.svg?branch=master)](https://travis-ci.org/Yleisradio/yle_tf)

A wrapper for [Terraform](https://www.terraform.io/) with support for hooks and environments.

Offers a command-line helper tool, `tf`

## Getting started

YleTf requires Terraform which can be installed according to their [instructions](https://www.terraform.io/intro/getting-started/install.html). On MacOS (and OSX) you can use [Homebrew](https://brew.sh/). You can also easily install and manage multiple versions of Terraform with [homebrew-terraforms](https://github.com/Yleisradio/homebrew-terraforms).

## Installation

YleTf can be installed as a gem:

```sh
$ gem install yle_tf
```

## Usage

The syntax to run YleTf is much like vanilla [Terraform](https://terraform.io). The main difference is that you must include desired environment as the first argument:

```
tf <environment> <command> [<args>]
```

For example:

```
$ tf test plan

$ tf prod apply

$ tf stage destroy
```

For a full list of available options, run `tf --help`.

When `tf` is executed, it creates a temporary directory where your project is copied and initialized.

### Example project

The following is a really basic example on what you need in order to use YleTf. The project is pretty much the same as the [example project](https://www.terraform.io/intro/getting-started/build.html) in Terraform documentation but with the added support for environments. Introduction to [hooks](#hooks) is in it's own section.

#### Project Config

The root of your project directory will look like this:

```
.
├── envs
│   ├── prod.tfvars
│   └── test.tfvars
├── main.tf
├── tf.yaml
└── variables.tf
```

And here are the contents of the files:

##### main.tf

```hcl
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
```

_Please note that the AMI identifier changes based on your desired OS and region. For more information see [AWS documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)._

##### variables.tf

```hcl
variable "region" {
  description = "The AWS region for the resources"
  default     = "eu-west-1"
}

variable "env" {
  # passed by `tf`
  description = "The environment"
}

variable "aws_access_key" {
  description = "Your AWS access key id"
}

variable "aws_secret_key" {
  description = "Your AWS secret key"
}

variable "instance_type" {
  description = "Instance type to use"
  default = "t2.micro"
}
```

##### envs/test.tfvars

```ini
aws_access_key = "TEST_ACCOUNT_ACCESS_KEY_HERE"
aws_secret_key = "TEST_ACCOUNT_SECRET_KEY_HERE"
```

##### tf.yaml

```yaml
backend:
  type: file
terraform:
  version_requirement: "~> 0.9.11"
```

#### Execution

With all the above in order, there's nothing more to do than to try and run the commands:

First plan:

```
$ tf test plan
INFO: Symlinking state to '/usr/local/src/yle_tf/examples/examples_test.tfstate'

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your environment. If you forget, other
commands will detect it and remind you to do so if necessary.
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

+ aws_instance.example
    ami:                          "ami-d7b9a2b1"
    associate_public_ip_address:  "<computed>"
    availability_zone:            "<computed>"
    ebs_block_device.#:           "<computed>"
    ephemeral_block_device.#:     "<computed>"
    instance_state:               "<computed>"
    instance_type:                "t2.micro"
    ipv6_address_count:           "<computed>"
    ipv6_addresses.#:             "<computed>"
    key_name:                     "<computed>"
    network_interface.#:          "<computed>"
    network_interface_id:         "<computed>"
    placement_group:              "<computed>"
    primary_network_interface_id: "<computed>"
    private_dns:                  "<computed>"
    private_ip:                   "<computed>"
    public_dns:                   "<computed>"
    public_ip:                    "<computed>"
    root_block_device.#:          "<computed>"
    security_groups.#:            "<computed>"
    source_dest_check:            "true"
    subnet_id:                    "<computed>"
    tenancy:                      "<computed>"
    volume_tags.%:                "<computed>"
    vpc_security_group_ids.#:     "<computed>"


Plan: 1 to add, 0 to change, 0 to destroy.
```

Then apply:

```
$ tf test apply

< SNIP >

aws_instance.example: Creating...
  ami:                          "" => "ami-d7b9a2b1"
  associate_public_ip_address:  "" => "<computed>"
  availability_zone:            "" => "<computed>"
  ebs_block_device.#:           "" => "<computed>"
  ephemeral_block_device.#:     "" => "<computed>"
  instance_state:               "" => "<computed>"
  instance_type:                "" => "t2.micro"
  ipv6_address_count:           "" => "<computed>"
  ipv6_addresses.#:             "" => "<computed>"
  key_name:                     "" => "<computed>"
  network_interface.#:          "" => "<computed>"
  network_interface_id:         "" => "<computed>"
  placement_group:              "" => "<computed>"
  primary_network_interface_id: "" => "<computed>"
  private_dns:                  "" => "<computed>"
  private_ip:                   "" => "<computed>"
  public_dns:                   "" => "<computed>"
  public_ip:                    "" => "<computed>"
  root_block_device.#:          "" => "<computed>"
  security_groups.#:            "" => "<computed>"
  source_dest_check:            "" => "true"
  subnet_id:                    "" => "<computed>"
  tenancy:                      "" => "<computed>"
  volume_tags.%:                "" => "<computed>"
  vpc_security_group_ids.#:     "" => "<computed>"
aws_instance.example: Still creating... (10s elapsed)
aws_instance.example: Still creating... (20s elapsed)
aws_instance.example: Creation complete (ID: i-0f1327bbc53fd6bab)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

< SNIP >
```

And when you're done using the infrastructure, destroy:

```
$ tf test destroy

< SNIP >

Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.example: Refreshing state... (ID: i-0f1327bbc53fd6bab)
aws_instance.example: Destroying... (ID: i-0f1327bbc53fd6bab)
aws_instance.example: Still destroying... (ID: i-0f1327bbc53fd6bab, 10s elapsed)
aws_instance.example: Still destroying... (ID: i-0f1327bbc53fd6bab, 20s elapsed)
aws_instance.example: Still destroying... (ID: i-0f1327bbc53fd6bab, 30s elapsed)
aws_instance.example: Still destroying... (ID: i-0f1327bbc53fd6bab, 40s elapsed)
aws_instance.example: Still destroying... (ID: i-0f1327bbc53fd6bab, 50s elapsed)
aws_instance.example: Still destroying... (ID: i-0f1327bbc53fd6bab, 1m0s elapsed)
aws_instance.example: Still destroying... (ID: i-0f1327bbc53fd6bab, 1m10s elapsed)
aws_instance.example: Destruction complete

Destroy complete! Resources: 1 destroyed.
```

#### Production environment

Now that we've tried that everything works in the test environment, let's do the same in production. Note that you can override variables if needed:

##### envs/prod.tfvars

```ini
aws_access_key = "PRODUCTION_ACCOUNT_ACCESS_KEY_HERE"
aws_secret_key = "PRODUCTION_ACCOUNT_SECRET_KEY_HERE"

# let's use a bigger instance type in prod
instance_type = "t2.medium"
```

And run the commands just like with _test_:

```
$ tf prod plan

< SNIP >

$ tf prod apply

< SNIP >

$ tf prod destroy

< SNIP >
```

_Note that the instance type is now t2.medium_

## Default components

### tf.yaml

Here be dragons that configure your project. The tools serches for `tf.yaml`'s up your path all the way to root `/`. Configs made in subdirectories override those made upper in the path. This makes it easy to define common settings without having to edit `tf.yaml` in every project.

By defalt the following configuration options are supported:
* [`hooks`](#hooks) - Pre and Post hooks.
* [`backend`](#backend) - Configuration of remote state location.
* [`terraform`](#terraform) - Terraform specific configuration.

#### Hooks

There are cases when it would be beneficial to run a task at the same time as terrafrom, but building native support for that would be quite cumbersome. The support for hooks was build into YleTf having those cases in mind.

Essentially hooks are just scripts and small applications to extend the functionality of Terraform. Hooks can be either
* [local](#local-hooks) or
* [remote](#remote-hooks) i.e. stored into git.

Real world usecases for hooks include at least the following:
* Automatically register ACM certificates and link them to desired resources
* Automatically generate dns record resources that are managed by separate configuration
* Package lambda applications for deployment via Terraform
* Manage SES authorisations and rules
* Modify parameters not yet supported by Terraform

Currently two kinds of hooks are supported:
* `pre` - Hooks that run before terraform execution.
* `post` - Hooks that run after terraform execution.

#### Local hooks

For local hooks, add a directory called `tf_hooks` to your tf project root. You also need a folder to determine wether the hook is run before or after the execution of terraform. The folders are `pre` and/or `post`:

```
.
├── envs
│   ├── prod.tfvars
│   └── test.tfvars
├── main.tf
├── tf.yaml
├── tf_hooks
│   ├── pre
│   │   └── pre-hook.sh
│   └── post
│   │   └── post-hook.rb
└── variables.tf
```

For example, let's say you wish to have a variable `current_git_hash` and you want to populate it with a value of the latest git commit hash. The hook could be something like this:

##### tf_hooks/pre/get_current_hash.sh

```bash
#!/bin/bash

set -eu

current_hash() {
  CURRENT_GIT_HASH="$(git rev-parse HEAD)"

  cat <<EOF > current_git_hash.tf.json
{
  "variable": {
    "current_git_hash": {
      "value": "$CURRENT_GIT_HASH"
    }
  }
}
EOF
}

# Execute only for commands `plan` and `apply`
case "$TF_COMMAND" in
  plan|apply)
    current_hash
    ;;
  *)
    ;;
esac
```

_Please note that the script in the [examples](examples/) directory is intentionnally without the execute bit._

Once you set the hook script executable (`chmod +x tf_hooks/pre/get_current_hash.sh`) and run `tf` with either `plan` or `apply`, you'll have the following file during runtime:

##### current_git_hash.tf.json

```json
{
  "variable": {
    "current_git_hash": {
      "value": "c6a02baf0597e55d7698f78d70299ca4a65776cd"
    }
  }
}
```

_Naturraly the actual value varies according to your repository._

_**Please note that files generated into the temporary working directory while running hooks are removed once the execution has ended.**_

#### Remote hooks

Hooks can also be stored in common git repositories. This is a handy way to avoid duplication in codebase.
To use a hook from git just add your script to a suitable repository (making sure it's still executable) and add following config to your `tf.yaml`:

##### tf.yaml

```yaml
hooks:
  pre:
    - description: "Get your current git commit hash"
      source: "git@github.com:your-org/tf-hooks.git//git-hash/get_current_hash.sh"
      vars:
        defaults:
          MESSAGE: "You can also define environment variables to your hooks"
        test:
          MESSAGE: "And the variables can also be environment spesific"
```

#### Backend

Configure where Terraform [remote state](https://www.terraform.io/docs/state/remote.html) is stored

* `type` - Backend type where the Terraform state is stored.
* `bucket` - The name of the S3 bucket.
* `file` - The name of the state file.
* `region` - The region of the S3 bucket.
* `encrypt` - Whether to enable server side encryption of the state file.

```yaml
backend:
  type: s3
```

#### Terraform

* `version_requirement` - The version requirement of Terraform in ruby gem syntax.

```yaml
terraform:
  version_requirement: "~> 0.9.11"
```

## Plugins

Available plugins are listed on the [wiki page](https://github.com/Yleisradio/yle_tf/wiki#plugins)

## Development

After checking out the repo, run `bundle update` to install and update the dependencies. Then, run `bundle exec rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Yleisradio/yle_tf. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
