# frozen_string_literal: true

require 'serverspec'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# ServerSpec configuration
set :backend, :exec
set :path, "#{File.expand_path('../bin', __dir__)}:#{__dir__}/support/bin:$PATH"

# Ensure that `TF_PLUGINS` is empty
ENV.delete 'TF_PLUGINS'
