# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qma/version'

Gem::Specification.new do |spec|
  spec.name            = 'qyer-mobile-app'
  spec.version         = QMA::VERSION
  spec.authors         = QMA::AUTHORS.keys
  spec.email           = QMA::AUTHORS.values
  spec.summary         = QMA::SUMMARY
  spec.description     = QMA::DESCRIPTION
  spec.homepage        = 'http://github.com/icyleaf/qyer-mobile-app'
  spec.license         = 'MIT'
  spec.files           = `git ls-files -z`.split("\x0")
  spec.executables     = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files      = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths   = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'commander', '~> 4.4'
  spec.add_dependency 'terminal-table', '>= 1.4.5', '< 2.0.0'
  spec.add_dependency 'rest-client', '>= 2.0.0', '< 3.0'
  spec.add_dependency 'app-info', '~> 1.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
