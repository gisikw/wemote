# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wemote/version'

Gem::Specification.new do |spec|
  spec.name          = "wemote"
  spec.version       = Wemote::VERSION
  spec.authors       = ["Kevin Gisi"]
  spec.email         = ["kevin@kevingisi.com"]
  spec.description   = %q{Wemote is a Ruby-agnostic gem for Wemo light switches}
  spec.summary       = %q{Wemote is a Ruby-agnostic gem for Wemo light switches}
  spec.homepage      = "https://github.com/gisikw/wemote"
  spec.license       = "MIT"
  spec.platform      = 'ruby'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
