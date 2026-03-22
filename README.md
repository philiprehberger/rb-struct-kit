# philiprehberger-struct_kit

[![Tests](https://github.com/philiprehberger/rb-struct-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-struct-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-struct_kit.svg)](https://rubygems.org/gems/philiprehberger-struct_kit)
[![License](https://img.shields.io/github/license/philiprehberger/rb-struct-kit)](LICENSE)

Enhanced struct builder with typed fields, defaults, validation, and pattern matching

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem 'philiprehberger-struct_kit'
```

Or install directly:

```bash
gem install philiprehberger-struct_kit
```

## Usage

```ruby
require 'philiprehberger/struct_kit'

User = Philiprehberger::StructKit.define do
  field :name, String
  field :age, Integer, default: 0
  field :role, Symbol, default: :user
  validate :age, range: 0..150
end

user = User.new(name: 'Alice', age: 30)
user.name   # => "Alice"
user.age    # => 30
user.role   # => :user
```

### Defaults

```ruby
Config = Philiprehberger::StructKit.define do
  field :timeout, Integer, default: 30
  field :tags, Array, default: -> { [] }
end

config = Config.new
config.timeout  # => 30
config.tags     # => []
```

### Type Coercion

```ruby
Record = Philiprehberger::StructKit.define do
  field :count, Integer, default: 0, coerce: ->(v) { v.to_i }
end

record = Record.new(count: '42')
record.count  # => 42
```

### Validation

```ruby
user = User.new(name: 'Alice', age: 200)
user.valid?   # => false
user.errors   # => ["age must be in range 0..150"]
```

### Immutability

```ruby
user = User.new(name: 'Alice')
user.frozen?  # => true

updated = user.merge(age: 31)  # returns new instance
updated.age  # => 31
user.age     # => 0 (unchanged)
```

### Hash Serialization

```ruby
user = User.new(name: 'Alice', age: 30)
user.to_h  # => { name: "Alice", age: 30, role: :user }

User.from_h({ name: 'Bob', age: 25 })
```

### Pattern Matching

```ruby
user = User.new(name: 'Alice', role: :admin)

case user
in { role: :admin }
  puts 'Admin user'
in { role: :user }
  puts 'Regular user'
end
```

## API

### `Philiprehberger::StructKit`

| Method | Description |
|--------|-------------|
| `.define { block }` | Define a new struct class with the DSL |

### DSL (inside `define` block)

| Method | Description |
|--------|-------------|
| `field :name, Type, default:, coerce:` | Define a typed field with optional default and coercion |
| `validate :name, range:, format:` | Add validation rules to a field |

### Instance Methods

| Method | Description |
|--------|-------------|
| `#to_h` | Convert to a plain hash |
| `#merge(**attrs)` | Return a new instance with merged attributes |
| `#valid?` | Whether all validations pass |
| `#errors` | Array of validation error messages |
| `#deconstruct_keys(keys)` | Pattern matching support |

### Class Methods

| Method | Description |
|--------|-------------|
| `.from_h(hash)` | Construct from a hash (string or symbol keys) |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
