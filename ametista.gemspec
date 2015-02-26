  # coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ametista/version'

Gem::Specification.new do |spec|
  spec.name          = "ametista"
  spec.version       = Ametista::VERSION
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
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rails-erd"

  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "pg"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "activerecord", "~> 4"
  spec.add_runtime_dependency "active_record_migrations"
  spec.add_runtime_dependency "awesome_print"
  spec.add_runtime_dependency "global"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "virtus"
  spec.add_runtime_dependency "ancestry"
end
