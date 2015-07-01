# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qma/version'

Gem::Specification.new do |spec|
  spec.name                  = 'qyer-mobile-app'
  spec.version               = QMA::VERSION
  spec.authors               = QMA::AUTHORS.keys
  spec.email                 = QMA::AUTHORS.values
  spec.summary               = %q{穷游移动应用命令行工具}
  spec.description           = %q{穷游移动应用命令行工具：App 打包，上传等}
  spec.homepage              = "http://github.com/icyleaf/qyer-mobile-app"
  spec.license               = "MIT"

  spec.files                 = `git ls-files -z`.split("\x0")
  spec.executables           = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files            = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths         = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2.0"

  spec.add_dependency 'rest-client', '~> 1.7'
  spec.add_dependency 'multi_json', '~> 1.11.1'
  spec.add_dependency 'app_config', '~> 2.5.3'
  spec.add_dependency 'awesome_print', '~> 1.6.1'

  spec.add_dependency 'lagunitas', '0.0.2'
  spec.add_dependency 'commander', '~> 4.3.4'
  spec.add_dependency 'ruby_android', '~> 0.7.7'
end
