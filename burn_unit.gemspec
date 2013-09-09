# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'burn_unit/version'

Gem::Specification.new do |spec|
  spec.name          = 'burn_unit'
  spec.version       = BurnUnit::VERSION
  spec.authors       = ['Freewrite.org']
  spec.email         = ['dev@freewrite.org']
  spec.description   = %q{Test::Unit add-ons for Backburner}
  spec.summary       = %q{BurnUnit provides additional assertions for testing Ruby code that relies on Backburner}
  spec.homepage      = 'https://github.com/freewrite/burn_unit'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'backburner'
  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'stalk_climber'
end
