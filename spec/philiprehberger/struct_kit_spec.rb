# frozen_string_literal: true

RSpec.describe Philiprehberger::StructKit do
  describe '.define' do
    let(:user_class) do
      described_class.define do
        field :name, String
        field :age, Integer, default: 0
        field :role, Symbol, default: :user
      end
    end

    it 'creates a class with attribute readers' do
      user = user_class.new(name: 'Alice', age: 30)
      expect(user.name).to eq('Alice')
      expect(user.age).to eq(30)
      expect(user.role).to eq(:user)
    end

    it 'applies default values' do
      user = user_class.new(name: 'Bob')
      expect(user.age).to eq(0)
      expect(user.role).to eq(:user)
    end

    it 'raises ArgumentError for missing required fields' do
      expect { user_class.new(age: 25) }.to raise_error(ArgumentError, /missing keyword: name/)
    end

    it 'raises TypeError for wrong type' do
      expect { user_class.new(name: 123) }.to raise_error(TypeError, /name must be a String/)
    end

    it 'freezes instances by default' do
      user = user_class.new(name: 'Alice')
      expect(user).to be_frozen
    end
  end

  describe 'lambda defaults' do
    let(:klass) do
      described_class.define do
        field :items, Array, default: -> { [] }
      end
    end

    it 'calls lambda for each instance' do
      a = klass.new
      b = klass.new
      expect(a.items.object_id).not_to eq(b.items.object_id)
    end
  end

  describe 'coercion' do
    let(:klass) do
      described_class.define do
        field :count, Integer, default: 0, coerce: ->(v) { v.to_i }
      end
    end

    it 'coerces values' do
      instance = klass.new(count: '42')
      expect(instance.count).to eq(42)
    end
  end

  describe '#to_h' do
    let(:klass) do
      described_class.define do
        field :name, String
        field :age, Integer, default: 0
      end
    end

    it 'converts to hash' do
      instance = klass.new(name: 'Alice', age: 30)
      expect(instance.to_h).to eq({ name: 'Alice', age: 30 })
    end
  end

  describe '#merge' do
    let(:klass) do
      described_class.define do
        field :name, String
        field :age, Integer, default: 0
      end
    end

    it 'returns new instance with merged attributes' do
      original = klass.new(name: 'Alice', age: 30)
      updated = original.merge(age: 31)
      expect(updated.age).to eq(31)
      expect(original.age).to eq(30)
    end
  end

  describe '#==' do
    let(:klass) do
      described_class.define do
        field :name, String
      end
    end

    it 'compares by value' do
      a = klass.new(name: 'Alice')
      b = klass.new(name: 'Alice')
      expect(a).to eq(b)
    end

    it 'is false for different values' do
      a = klass.new(name: 'Alice')
      b = klass.new(name: 'Bob')
      expect(a).not_to eq(b)
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
    end

    it 'constructs from hash with string keys' do
      instance = klass.from_h({ 'name' => 'Alice', 'age' => 25 })
      expect(instance.name).to eq('Alice')
    end
  end

  describe 'pattern matching' do
    let(:klass) do
      described_class.define do
        field :name, String
        field :role, Symbol, default: :user
      end
    end

    it 'supports deconstruct_keys' do
      instance = klass.new(name: 'Alice')
      result = instance.deconstruct_keys([:name])
      expect(result).to eq({ name: 'Alice' })
    end

    it 'returns all keys when nil passed' do
      instance = klass.new(name: 'Alice')
      result = instance.deconstruct_keys(nil)
      expect(result).to eq({ name: 'Alice', role: :user })
    end
  end
end
