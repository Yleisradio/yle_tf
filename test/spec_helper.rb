# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# Ensure that `TF_PLUGINS` is empty
ENV.delete 'TF_PLUGINS'

RSpec.configure do |config|
  config.formatter = :documentation

  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # run the examples in random order
  config.order = :rand
end
