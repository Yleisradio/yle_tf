# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
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

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'bin'
  spec.executables   = ['tf']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
end
