# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'remo/version'

Gem::Specification.new do |spec|
  spec.name          = "remo"
  spec.version       = Remo::VERSION
  spec.authors       = ["Kevin Gisi"]
  spec.email         = ["kevin@kevingisi.com"]
  spec.description   = %q{Remo is a JRuby-friendly API for Wemo light switches}
  spec.summary       = %q{Remo is a JRuby-friendly API for Wemo light switches}
  spec.homepage      = "https://github.com/gisikw/remo"
  spec.license       = "MIT"
  spec.platform      = 'ruby'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "manticore", "~> 0.2.1"
end
