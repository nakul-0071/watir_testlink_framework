# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'watir_testlink_framework/version'

Gem::Specification.new do |spec|
  spec.name          = "watir_testlink_framework"
  spec.version       = WatirTestlinkFramework::VERSION
  spec.authors       = ["Pim Snel"]
  spec.email         = ["pim@lingewoud.nl"]
  spec.summary       = %q{Framework for testing website with Watir & TestLink}
  spec.description   = %q{Watir TestLink Framework combines a lot of fine software like Watir, TestLink, Rspec, Rake, Junit to make it easy to run large sets of watir test cases on different stages of sites.}
  spec.homepage      = "https://github.com/Lingewoud/watir_testlink_framework"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"

  spec.add_runtime_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "rspec", "~> 3.1"
  spec.add_runtime_dependency "rspec_testlink_formatters", "~> 0"
  spec.add_runtime_dependency "testlink_rspec_utils", "~> 0"
#  spec.add_runtime_dependency "watir", "~> 5.0"
#  spec.add_runtime_dependency "headless", "~> 1.0"
end
