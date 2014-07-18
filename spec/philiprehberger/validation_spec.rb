# frozen_string_literal: true
require 'spec_helper'
RSpec.describe Philiprehberger::StructKit::Validation do
  let(:klass) do
    Philiprehberger::StructKit.define do
      field :name, String
      field :age, Integer, default: 0
      validate :age, range: 0..150
    end
  end

  describe '#valid?' do
    it 'returns true for valid instance' do
      instance = klass.new(name: 'Alice', age: 25)
      expect(instance).to be_valid
    end

    it 'returns false for invalid age' do
      instance = klass.new(name: 'Alice', age: -1)
      expect(instance).not_to be_valid
    end

    it 'returns false for age over range' do
      instance = klass.new(name: 'Alice', age: 200)
      expect(instance).not_to be_valid
    end
  end

  describe '#errors' do
    it 'returns empty array for valid instance' do
      instance = klass.new(name: 'Alice', age: 25)
      expect(instance.errors).to be_empty
    end

    it 'returns error messages for invalid instance' do
      instance = klass.new(name: 'Alice', age: -1)
      expect(instance.errors).not_to be_empty
      expect(instance.errors.first).to include('range')
    end
  end
end
