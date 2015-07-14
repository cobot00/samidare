# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'samidare/version'

Gem::Specification.new do |spec|
  spec.name          = 'samidare'
  spec.version       = Samidare::VERSION
  spec.authors       = ['Ryoji Kobori']
  spec.email         = ['kobori75@gmail.com']
  spec.summary       = %q{Embulk utility for MySQL to BigQuery}
  spec.description   = %q{Generate Embulk config and BigQuery schema from MySQL schema}
  spec.homepage      = 'https://github.com/cobot00/samidare'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'unindent'

  spec.add_dependency 'mysql2-cs-bind'
  spec.add_dependency 'embulk-output-bigquery'
  spec.add_dependency 'embulk-input-mysql'
  spec.add_dependency 'embulk-output-mysql'
  spec.add_dependency 'embulk-parser-jsonl'
  spec.add_dependency 'embulk-formatter-jsonl'
  spec.add_dependency 'bigquery'
end
