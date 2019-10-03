# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yle_tf/version'

Gem::Specification.new do |spec|
  spec.name        = 'yle_tf'
  spec.version     = YleTf::VERSION
  spec.summary     = 'Tooling for Terraform'
  spec.description = 'Tooling for Terraform to support environments, hooks, etc.'
  spec.homepage    = 'https://github.com/Yleisradio/yle_tf'
  spec.license     = 'MIT'

  spec.authors = [
    'Yleisradio',
    'Teemu Matilainen',
    'Antti Forsell',
  ]
  spec.email = [
    'devops@yle.fi',
    'teemu.matilainen@iki.fi',
    'antti.forsell@iki.fi',
  ]

  spec.files = Dir['bin/**/*'] +
               Dir['lib/**/*.rb'] +
               Dir['vendor/**/*']

  spec.bindir        = 'bin'
  spec.executables   = ['tf']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'serverspec', '~> 2.41'
end
