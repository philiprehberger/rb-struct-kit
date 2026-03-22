# frozen_string_literal: true

require_relative 'field'
require_relative 'validation'

module Philiprehberger
  module StructKit
    class Definition
      def initialize
        @fields = {}
        @validations = {}
      end

      def field(name, type = nil, default: :__no_default__, coerce: nil)
        @fields[name] = Field.new(name, type, default: default, coerce: coerce)
      end

      def validate(name, **rules, &block)
        @validations[name] ||= []
        @validations[name] << rules unless rules.empty?
        @validations[name] << block if block
      end

      def build
        fields = @fields
        validations = @validations

        validations.each do |name, rules|
          next unless fields[name]

          rules.each { |rule| fields[name].add_validation(rule) }
        end

        klass = Class.new do
          include Validation

          define_method(:_fields_data) { fields }

          class << self
            attr_accessor :_fields
          end

          fields.each do |name, _field|
            attr_reader name
          end

          define_method(:initialize) do |**kwargs|
            self.class._fields.each do |name, f|
              value = if kwargs.key?(name)
                        kwargs[name]
                      elsif f.has_default?
                        f.resolve_default
                      else
                        raise ArgumentError, "missing keyword: #{name}"
                      end

              value = f.coerce_value(value)

              unless f.validate_type(value)
                raise TypeError, "#{name} must be a #{f.type}, got #{value.class}"
              end

              instance_variable_set(:"@#{name}", value)
            end

            freeze
          end

          define_method(:to_h) do
            self.class._fields.each_with_object({}) do |(name, _), hash|
              hash[name] = instance_variable_get(:"@#{name}")
            end
          end

          define_method(:merge) do |**attrs|
            self.class.new(**to_h.merge(attrs))
          end

          define_method(:==) do |other|
            other.is_a?(self.class) && to_h == other.to_h
          end

          define_method(:hash) do
            to_h.hash
          end

          define_method(:deconstruct_keys) do |keys|
            h = to_h
            keys ? h.slice(*keys) : h
          end

          define_method(:to_s) do
            fields_str = to_h.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
            "#<#{self.class.name || 'StructKit'} #{fields_str}>"
          end

          define_method(:inspect) { to_s }

          define_singleton_method(:from_h) do |hash|
            sym_hash = hash.transform_keys(&:to_sym)
            new(**sym_hash)
          end
        end

        klass._fields = fields
        klass
      end
    end
  end
end
