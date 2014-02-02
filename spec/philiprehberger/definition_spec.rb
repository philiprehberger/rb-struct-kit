# frozen_string_literal: true

RSpec.describe Philiprehberger::StructKit::Definition do
  describe '#field' do
    it 'registers fields with types' do
      defn = described_class.new
      defn.field(:name, String)
      klass = defn.build
      instance = klass.new(name: 'test')
      expect(instance.name).to eq('test')
    end

    it 'registers fields without types' do
      defn = described_class.new
      defn.field(:data)
      klass = defn.build
      instance = klass.new(data: [1, 2, 3])
      expect(instance.data).to eq([1, 2, 3])
    end

    it 'supports default values' do
      defn = described_class.new
      defn.field(:status, Symbol, default: :pending)
      klass = defn.build
      instance = klass.new
      expect(instance.status).to eq(:pending)
    end

    it 'supports coercion' do
      defn = described_class.new
      defn.field(:count, Integer, default: 0, coerce: ->(v) { v.to_i })
      klass = defn.build
      instance = klass.new(count: '5')
      expect(instance.count).to eq(5)
    end
  end

  describe '#validate' do
    it 'adds range validation' do
      defn = described_class.new
      defn.field(:age, Integer, default: 0)
      defn.validate(:age, range: 0..150)
      klass = defn.build

      instance = klass.new(age: 200)
      expect(instance).not_to be_valid
      expect(instance.errors).to include(a_string_matching(/range/))
    end

    it 'passes valid range' do
      defn = described_class.new
      defn.field(:age, Integer, default: 0)
      defn.validate(:age, range: 0..150)
      klass = defn.build

      instance = klass.new(age: 25)
      expect(instance).to be_valid
    end
  end

  describe '#build' do
    it 'returns a class' do
      defn = described_class.new
      defn.field(:x)
      expect(defn.build).to be_a(Class)
    end

    it 'creates frozen instances' do
      defn = described_class.new
      defn.field(:x)
      klass = defn.build
      expect(klass.new(x: 1)).to be_frozen
    end
  end
end
