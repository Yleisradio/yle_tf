## 0.2.2  / _Not released yet_

- Catch `Ctrl+C` to avoid stack traces

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
