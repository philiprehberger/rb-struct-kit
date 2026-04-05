# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe Philiprehberger::StructKit do
  it 'has a version number' do
    expect(Philiprehberger::StructKit::VERSION).not_to be_nil
  end

  describe '.define' do
    it 'creates a struct with fields and allows attribute access' do
      klass = described_class.define do
        field :name, String
        field :age, Integer, default: 0
      end

      user = klass.new(name: 'Alice', age: 30)
      expect(user.name).to eq('Alice')
      expect(user.age).to eq(30)
    end

    it 'raises TypeError for wrong type' do
      klass = described_class.define do
        field :name, String
      end

      expect { klass.new(name: 123) }.to raise_error(TypeError, /name must be String/)
    end

    it 'supports array of types' do
      klass = described_class.define do
        field :active, [TrueClass, FalseClass]
      end

      expect(klass.new(active: true).active).to be true
      expect(klass.new(active: false).active).to be false
      expect { klass.new(active: 'yes') }.to raise_error(TypeError)
    end

    it 'applies static default values' do
      klass = described_class.define do
        field :role, Symbol, default: :user
      end

      expect(klass.new.role).to eq(:user)
    end

    it 'applies lambda default values' do
      klass = described_class.define do
        field :items, Array, default: -> { [] }
      end

      a = klass.new
      b = klass.new
      expect(a.items).to eq([])
      expect(a.items.object_id).not_to eq(b.items.object_id)
    end

    it 'raises ArgumentError for missing required field' do
      klass = described_class.define do
        field :name, String
      end

      expect { klass.new }.to raise_error(ArgumentError, /missing keyword: name/)
    end
  end

  describe 'validation' do
    it 'validates range' do
      klass = described_class.define do
        field :age, Integer
        validate :age, range: 0..150
      end

      expect { klass.new(age: 200) }.to raise_error(ArgumentError, /range/)
      expect(klass.new(age: 25).age).to eq(25)
    end

    it 'validates format with regex' do
      klass = described_class.define do
        field :email, String
        validate :email, format: /@/
      end

      expect { klass.new(email: 'invalid') }.to raise_error(ArgumentError, /format/)
      expect(klass.new(email: 'a@b.com').email).to eq('a@b.com')
    end

    it 'validates with custom block' do
      klass = described_class.define do
        field :name, String
        validate(:name) { |v| 'must not be empty' if v.empty? }
      end

      expect { klass.new(name: '') }.to raise_error(ArgumentError, /must not be empty/)
      expect(klass.new(name: 'Alice').name).to eq('Alice')
    end
  end

  describe 'frozen by default' do
    it 'freezes instances' do
      klass = described_class.define do
        field :name, String
      end

      user = klass.new(name: 'Alice')
      expect(user).to be_frozen
    end

    it 'raises FrozenError on mutation attempt' do
      klass = described_class.define do
        field :name, String
      end

      user = klass.new(name: 'Alice')
      expect { user.instance_variable_set(:@name, 'Bob') }.to raise_error(FrozenError)
    end
  end

  describe 'mutable: true' do
    it 'does not freeze instances' do
      klass = described_class.define(mutable: true) do
        field :name, String
      end

      user = klass.new(name: 'Alice')
      expect(user).not_to be_frozen
    end

    it 'allows mutations via writers' do
      klass = described_class.define(mutable: true) do
        field :name, String
      end

      user = klass.new(name: 'Alice')
      user.name = 'Bob'
      expect(user.name).to eq('Bob')
    end
  end

  describe '#to_h' do
    it 'returns hash of field values' do
      klass = described_class.define do
        field :name, String
        field :age, Integer, default: 0
      end

      user = klass.new(name: 'Alice', age: 30)
      expect(user.to_h).to eq({ name: 'Alice', age: 30 })
    end
  end

  describe '#to_json' do
    it 'returns JSON string' do
      klass = described_class.define do
        field :name, String
        field :count, Integer, default: 0
      end

      user = klass.new(name: 'Alice', count: 5)
      parsed = JSON.parse(user.to_json)
      expect(parsed['name']).to eq('Alice')
      expect(parsed['count']).to eq(5)
    end
  end

  describe '.from_h' do
    let(:klass) do
      described_class.define do
        field :name, String
        field :age, Integer, default: 0
      end
    end

    it 'constructs from hash with symbol keys' do
      instance = klass.from_h({ name: 'Alice', age: 25 })
      expect(instance.name).to eq('Alice')
      expect(instance.age).to eq(25)
    end

    it 'constructs from hash with string keys' do
      instance = klass.from_h({ 'name' => 'Alice', 'age' => 25 })
      expect(instance.name).to eq('Alice')
      expect(instance.age).to eq(25)
    end
  end

  describe '#deconstruct_keys' do
    it 'returns requested keys for pattern matching' do
      klass = described_class.define do
        field :name, String
        field :role, Symbol, default: :user
      end

      instance = klass.new(name: 'Alice')
      result = instance.deconstruct_keys([:name])
      expect(result).to eq({ name: 'Alice' })
    end

    it 'returns all keys when nil passed' do
      klass = described_class.define do
        field :name, String
        field :role, Symbol, default: :user
      end

      instance = klass.new(name: 'Alice')
      result = instance.deconstruct_keys(nil)
      expect(result).to eq({ name: 'Alice', role: :user })
    end
  end

  describe '#==' do
    let(:klass) do
      described_class.define do
        field :name, String
        field :age, Integer, default: 0
      end
    end

    it 'is equal for same field values' do
      a = klass.new(name: 'Alice', age: 30)
      b = klass.new(name: 'Alice', age: 30)
      expect(a).to eq(b)
    end

    it 'is not equal for different field values' do
      a = klass.new(name: 'Alice', age: 30)
      b = klass.new(name: 'Bob', age: 30)
      expect(a).not_to eq(b)
    end
  end

  describe '#inspect' do
    it 'returns a nice string representation' do
      klass = described_class.define do
        field :name, String
      end

      user = klass.new(name: 'Alice')
      expect(user.inspect).to include('name: "Alice"')
    end
  end

  describe 'coercion' do
    it 'coerces values with a custom lambda' do
      klass = described_class.define do
        field :age, Integer, coerce: ->(v) { Integer(v) }
      end
      instance = klass.new(age: '25')
      expect(instance.age).to eq(25)
    end

    it 'coerces before type checking' do
      klass = described_class.define do
        field :count, Integer, coerce: ->(v) { Integer(v) }
      end
      expect { klass.new(count: '10') }.not_to raise_error
    end

    it 'coerces before validation' do
      klass = described_class.define do
        field :age, Integer, coerce: ->(v) { Integer(v) }
        validate :age, range: 0..150
      end
      instance = klass.new(age: '25')
      expect(instance.age).to eq(25)
    end

    it 'raises when coercion fails' do
      klass = described_class.define do
        field :age, Integer, coerce: ->(v) { Integer(v) }
      end
      expect { klass.new(age: 'not_a_number') }.to raise_error(ArgumentError)
    end

    it 'skips coercion when not specified' do
      klass = described_class.define do
        field :name, String
      end
      instance = klass.new(name: 'hello')
      expect(instance.name).to eq('hello')
    end

    it 'works with to_s coercion' do
      klass = described_class.define do
        field :label, String, coerce: lambda(&:to_s)
      end
      instance = klass.new(label: 42)
      expect(instance.label).to eq('42')
    end

    it 'works with to_sym coercion' do
      klass = described_class.define do
        field :status, Symbol, coerce: lambda(&:to_sym)
      end
      instance = klass.new(status: 'active')
      expect(instance.status).to eq(:active)
    end
  end

  describe 'multiple struct definitions' do
    it 'creates independent classes' do
      klass_a = described_class.define do
        field :x, Integer
      end

      klass_b = described_class.define do
        field :y, String
      end

      a = klass_a.new(x: 1)
      b = klass_b.new(y: 'hello')

      expect(a).not_to eq(b)
      expect(a).to respond_to(:x)
      expect(a).not_to respond_to(:y)
      expect(b).to respond_to(:y)
      expect(b).not_to respond_to(:x)
    end
  end
end
