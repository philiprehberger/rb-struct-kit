# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-21

### Added
- Initial release
- DSL-based struct definition with `StructKit.define`
- Typed fields with runtime type checking
- Default values (static and lambda)
- Value coercion via `coerce:` option
- Validation rules (range, format, custom blocks)
- Immutable instances (frozen by default)
- `#to_h` and `.from_h` for hash serialization
- `#merge` for creating modified copies
- Pattern matching support via `deconstruct_keys`
