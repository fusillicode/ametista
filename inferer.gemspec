# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inferer/version'

Gem::Specification.new do |spec|
  spec.name          = "inferer"
  spec.version       = Inferer::VERSION
  spec.authors       = ["fusillicode"]
  spec.email         = ["fusillicode@gmail.com"]
  spec.summary       = %q{...}
  spec.description   = %q{...}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "mongoid"
end
