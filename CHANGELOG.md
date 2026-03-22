# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
n## [0.1.3] - 2026-03-22

### Changed
- Add License badge to README

## [0.1.2] - 2026-03-22

### Fixed

- Fix CHANGELOG header wording
- Add bug_tracker_uri to gemspec

## [0.1.1] - 2026-03-22

### Changed
- Improve source code, tests, and rubocop compliance

## [0.1.0] - 2026-03-22

### Added

- Initial release
- DSL-based struct definition with `StructKit.define`
- Typed fields with runtime type checking (single class or array of classes)
- Default values (static and lambda)
- Validation rules (range, format regex, custom blocks)
- Immutable instances by default (frozen after initialization)
- Mutable variant with `StructKit.define(mutable: true)`
- `#to_h` and `.from_h` for hash serialization (string keys accepted)
- `#to_json` for JSON serialization
- Pattern matching support via `#deconstruct_keys`
- Value equality via `#==`
- Keyword-only constructor

[Unreleased]: https://github.com/philiprehberger/rb-struct-kit/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/philiprehberger/rb-struct-kit/releases/tag/v0.1.0
