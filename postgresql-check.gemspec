# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postgresql/check/version'

Gem::Specification.new do |spec|
  spec.name          = 'postgresql-check'
  spec.version       = Postgresql::Check::VERSION
  spec.authors       = ['Alexei Mikhailov']
  spec.email         = ['amikhailov83@gmail.com']
  spec.summary       = %q{Adds helpers to migrations and dumps check constraints to schema.rb}
  spec.homepage      = 'https://github.com/take-five/postgresql-check'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 3.2.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
