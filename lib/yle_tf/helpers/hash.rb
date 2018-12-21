# frozen_string_literal: true

require_relative '../../../vendor/hash_deep_merge'

class YleTf
  module Helpers
    module Hash
      module_function

      # Returns deep merged new Hash
      def deep_merge(target, source)
        target.deep_merge(source)
      end

      # Returns deep copy of a Hash.
      # `dup` and `clone` only return shallow copies.
      def deep_copy(hash)
        Marshal.load(Marshal.dump(hash))
      end
    end
  end
end
