## 1.4.1 / _Not released yet_

Compatibility:

- Handle TF_LOG=TRACE in similar fashion as DEBUG ([GH-41](https://github.com/Yleisradio/yle_tf/pull/41/))
- Add Terrafrom 1.0 to tested versions. ([GH-43](https://github.com/Yleisradio/yle_tf/pull/43))
- Changed CI environment from Travis-CI to GitHub Actions ([GH-44](https://github.com/Yleisradio/yle_tf/pull/45))
- Dropped support for Ruby versions 2.4 and 2.5 and Terraform versions 0.9 and 0.10. ([GH-45](https://github.com/Yleisradio/yle_tf/pull/46))

Bugfixes:

- Interpret terraform hooks output as UTF-8. ([GH-42](https://github.com/Yleisradio/yle_tf/pull/42) & [GH-44](https://github.com/Yleisradio/yle_tf/pull/44))

## 1.4.0 / 2021-01-21

This release includes mainly fixes and features for Terraform 0.14 compatibility:

- Store the Terraform 0.14+ version lock file by copying it after `terraform init`. Add more control for the initialization by supporting `tf <env> init` command, and by adding `TF_INIT_ARGS` env var. ([GH-36](https://github.com/Yleisradio/yle_tf/pull/36))
- Write `terraformrc` only if it doesn't exist. This allows disabling the plugin cache (for [multi-arch lock file](https://github.com/hashicorp/terraform/issues/27388#issuecomment-756193826)), even if it slows down YleTf by causing provider downloads on each run. ([GH-39](https://github.com/Yleisradio/yle_tf/pull/39))
- Fix `--help` with Terraform 0.14 by not even trying to list all Terraform commands. You can get them with `terraform -help`.  ([GH-38](https://github.com/Yleisradio/yle_tf/pull/38))
- Add Terraform 0.14 and Ruby 3.0 to tested versions, drop testing for older Terraform versions than 0.11 (should still work with 0.9+) ([GH-35](https://github.com/Yleisradio/yle_tf/pull/35))

New features:

- Add experimental support for encrypting file backend states. See the PR for more details: ([GH-40](https://github.com/Yleisradio/yle_tf/pull/40))

## 1.3.0 / 2020-10-12

Improvements:

- Symlink `errored.tfstate` from run dir to module dir ([GH-31](https://github.com/Yleisradio/yle_tf/pull/31))

Compatibility:

- Support Ruby 2.7 ([GH-30](https://github.com/Yleisradio/yle_tf/pull/30))
- Drop Ruby 2.3 from the test matrix. Document the supported versions. ([GH-28](https://github.com/Yleisradio/yle_tf/pull/28), [GH-26](https://github.com/Yleisradio/yle_tf/pull/26))
- Add Terraform 0.12 and 0.13 to the test matrix. Document the supported versions. ([GH-27](https://github.com/Yleisradio/yle_tf/pull/27))

Bug fixes:

- Use `$HOME` instead of `~` in default .terraformrc ([GH-29](https://github.com/Yleisradio/yle_tf/pull/29))

## 1.2.0 / 2019-01-24

New features:

- Allow configuring YleTf version requirement in tf.yaml ([GH-25](https://github.com/Yleisradio/yle_tf/pull/25))
- Pass original module directory to hooks as `TF_MODULE_DIR` env var ([GH-24](https://github.com/Yleisradio/yle_tf/pull/24))

## 1.1.0 / 2019-01-05

Compatibility:

- Drop (already broken) support for Terraform 0.8 and older ([GH-22](https://github.com/Yleisradio/yle_tf/pull/22))
- Drop Ruby 2.2 support ([GH-15](https://github.com/Yleisradio/yle_tf/pull/15))
- Backend plugin interface has changed and is not compatible with the old one. The old configuration is automatically migrated, though. ([GH-18](https://github.com/Yleisradio/yle_tf/pull/18))

New features:

- Support all Terraform backends and all their attributes ([GH-18](https://github.com/Yleisradio/yle_tf/pull/18))
    * The `file` backend is still default (and should probably be used instead of Terraform's `local` backend).
    * Backend configuration has changes. See [the migration guide](https://github.com/Yleisradio/yle_tf/wiki/Migrating-Configuration) for more details.
- Support maps and lists in `tf_vars` ([GH-14](https://github.com/Yleisradio/yle_tf/pull/14), [GH-17](https://github.com/Yleisradio/yle_tf/pull/17))
    * Also add `module_dir` to the configuration evaluation context

Improvements:

- Improved tests! For example:
    * Test also with Ruby 2.6 ([GH-19](https://github.com/Yleisradio/yle_tf/pull/19))
    * Add some acceptance tests for Terraform versions 0.9 - 0.11 ([GH-20](https://github.com/Yleisradio/yle_tf/pull/20))
    * Add more unit tests

Bug fixes:

- Remove tmp dirs securely, but with force ([ad96a4fb](https://github.com/Yleisradio/yle_tf/commit/ad96a4fb))
- Fix configuration access when the key chain is not a Hash ([GH-19](https://github.com/Yleisradio/yle_tf/pull/19), [2de9c2e7](https://github.com/Yleisradio/yle_tf/commit/2de9c2e7))
- Fix some debug output cases

## 1.0.0  / 2018-09-10

Seems that the project is stable enough for v1.0! \o/

Only change after 0.4.0 is:

- Add support for OpenStack Swift backend ([GH-13](https://github.com/Yleisradio/yle_tf/pull/13))

## 0.4.0  / 2018-03-12

- Write default Terraform CLI configuration ([GH-10](https://github.com/Yleisradio/yle_tf/pull/10))
- Handle IOErrors in IO Handlers ([GH-11](https://github.com/Yleisradio/yle_tf/pull/11))

## 0.3.0  / 2018-01-26

- Catch `Ctrl+C` to avoid stack traces
- Fix Ruby 2.5 warnings from IO handler threads ([GH-6](https://github.com/Yleisradio/yle_tf/pull/6))
- Reduce debug level help output of the Terraform initialization ([GH-7](https://github.com/Yleisradio/yle_tf/pull/7))
- Deny interaction when initializing Terraform ([GH-9](https://github.com/Yleisradio/yle_tf/pull/9))

## 0.2.1  / 2017-09-19

- Default to colorful error messages only on a TTY ([GH-5](https://github.com/Yleisradio/yle_tf/pull/5))
- Remove extraneous debug output when loading bundler plugins

## 0.2.0 / 2017-09-18

New features:

- Support for IO handlers for `System.cmd` commands ([GH-4](https://github.com/Yleisradio/yle_tf/pull/4))
    * Pipe most command and hook output to Logger with reasonable log level
    * Add log level support for YleTf hook output

Improvements:

- Add colors for error and warning messages ([GH-3](https://github.com/Yleisradio/yle_tf/pull/3))
- Display better error message if tfvars files are not found

Bug fixes:

- Check that the temporary directories exist before removing them

## 0.1.1 / 2017-08-31

- Fix Bundler plugin loading errors ([GH-1](https://github.com/Yleisradio/yle_tf/pull/1))
- Declare that Ruby 2.2 or newer is required

## 0.1.0 / 2017-08-29

- Initial public release
