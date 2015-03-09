# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qyer/mobile/app/version'

Gem::Specification.new do |spec|
  spec.name          = "qyer-mobile-app"
  spec.version       = Qyer::Mobile::App::VERSION
  spec.authors       = ["icyleaf"]
  spec.email         = ["icyleaf.cn@gmail.com"]
  spec.summary       = %q{穷游移动应用命令行工具}
  spec.description   = %q{穷游移动应用命令行工具：App 打包，上传等}
  spec.homepage      = "http://qyer.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'lagunitas', '0.0.1'
  spec.add_dependency 'user_config', '0.0.4'
  spec.add_dependency 'pngdefry', '0.1.1'
  spec.add_dependency 'rest-client', '~> 1.7'
  spec.add_dependency 'paint', '~> 0.9'
  spec.add_dependency 'commander', '~> 4.3.0'
  spec.add_dependency 'ruby_apk', '~> 0.7'
  spec.add_dependency 'highline', '~> 1.6'
  spec.add_dependency 'rubyzip', '~> 0.9.9'
end
