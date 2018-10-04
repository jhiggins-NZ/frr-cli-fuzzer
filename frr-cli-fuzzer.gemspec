# coding: utf-8
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'frr-cli-fuzzer/version'

Gem::Specification.new do |spec|
  spec.name          = "frr-cli-fuzzer"
  spec.version       = FrrCliFuzzer::VERSION
  spec.authors       = ["Renato Westphal"]
  spec.email         = ["renato@opensourcerouting.org"]

  spec.summary       = %q{FRR CLI fuzzer.}
  spec.homepage      = "https://github.com/rwestphal/frr-cli-fuzzer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = "frr-cli-fuzzer"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "ffi"
end
