# frozen_string_literal: true

require_relative 'lib/philiprehberger/struct_kit/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-struct_kit'
  spec.version = Philiprehberger::StructKit::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Enhanced struct builder with typed fields, defaults, validation, and pattern matching'
  spec.description = 'Define data classes with typed fields, default values, validation rules, and ' \
                     'pattern matching support. Immutable by default with keyword-only construction, ' \
                     'JSON/Hash serialization, and runtime type checking.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-struct_kit'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-struct-kit'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-struct-kit/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-struct-kit/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
