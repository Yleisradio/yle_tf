# frozen_string_literal: true

module TestSupport
  module Env
    module_function

    def with_env(env)
      before = ENV.to_h.dup
      env.each { |k, v| ENV[k] = v }
      yield
    ensure
      ENV.replace(before)
    end
  end
end
