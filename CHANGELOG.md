## 1.0.1 / _Not released yet_


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
