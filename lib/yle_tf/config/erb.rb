# frozen_string_literal: true

require 'erb'

class YleTf
  class Config
    module ERB
      class Context
        def initialize(vars)
          vars.each { |key, value| instance_variable_set(:"@#{key}", value) }
        end

        # rubocop:disable Lint/UselessMethodDefinition
        def binding
          super
        end
        # rubocop:enable Lint/UselessMethodDefinition
      end

      def self.evaluate(string, vars = {})
        b = Context.new(vars).binding
        ::ERB.new(string).result(b)
      end
    end
  end
end
