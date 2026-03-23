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
user.frozen? # => true
```

### Type Checking

```ruby
Point = Philiprehberger::StructKit.define do
  field :x, Integer
  field :y, Integer
  field :active, [TrueClass, FalseClass], default: true
end

Point.new(x: 1, y: 2)            # OK
Point.new(x: 'a', y: 2)          # TypeError!
Point.new(x: 1, y: 2, active: 0) # TypeError!
```

### Default Values

```ruby
Config = Philiprehberger::StructKit.define do
  field :timeout, Integer, default: 30
  field :tags, Array, default: -> { [] }  # lambda for mutable defaults
end
```

### Validation

```ruby
Email = Philiprehberger::StructKit.define do
  field :address, String
  validate :address, format: /@/
end
```

### Mutable Structs

```ruby
MutableUser = Philiprehberger::StructKit.define(mutable: true) do
  field :name, String
  field :age, Integer, default: 0
end

user = MutableUser.new(name: 'Alice')
user.name = 'Bob'  # OK, not frozen
```

### Serialization

```ruby
user = User.new(name: 'Alice', age: 30)

user.to_h    # => { name: "Alice", age: 30, role: :user }
user.to_json # => '{"name":"Alice","age":30,"role":"user"}'

User.from_h({ 'name' => 'Bob', 'age' => 25 })  # string keys OK
```

### Pattern Matching

```ruby
case user
in { role: :admin }
  puts 'Admin user'
in { role: :user }
  puts 'Regular user'
end
```

## API

### `Philiprehberger::StructKit.define(mutable: false, &block)`

Define a new struct class. Evaluates the block in DSL context.

### DSL Methods

| Method | Description |
|--------|-------------|
| `field(name, type = nil, default: UNSET)` | Declare a typed field with optional default |
| `validate(name, range: nil, format: nil, &block)` | Add validation rule to a field |

### Instance Methods

| Method | Description |
|--------|-------------|
| `#to_h` | Convert to a plain hash |
| `#to_json` | Convert to JSON string |
| `#deconstruct_keys(keys)` | Pattern matching support |
| `#==` | Value equality |
| `#inspect` | Human-readable string representation |

### Class Methods

| Method | Description |
|--------|-------------|
| `.from_h(hash)` | Construct from hash (string or symbol keys) |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
