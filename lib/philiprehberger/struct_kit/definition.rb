# frozen_string_literal: true

require_relative 'field'

module Philiprehberger
  module StructKit
    class Definition
      def initialize(mutable: false)
        @fields = {}
        @validations = {}
        @mutable = mutable
      end

      def field(name, type = nil, default: Field::UNSET)
        @fields[name] = Field.new(name, type, default: default)
      end

      def validate(field_name, range: nil, format: nil, &block)
        @validations[field_name] ||= []
        rules = {}
        rules[:range] = range if range
        rules[:format] = format if format
        @validations[field_name] << rules unless rules.empty?
        @validations[field_name] << block if block
      end

      def build
        fields = @fields.dup
        mutable = @mutable

        # Attach validations to fields
        @validations.each do |name, rules|
          next unless fields[name]

          rules.each { |rule| fields[name].add_validation(rule) }
        end

        klass = Class.new do
          class << self
            attr_accessor :_fields, :_mutable
          end

          fields.each_key do |fname|
            attr_reader fname
          end

          define_method(:initialize) do |**kwargs|
            self.class._fields.each do |fname, f|
              value = if kwargs.key?(fname)
                        kwargs[fname]
                      elsif f.has_default?
                        f.resolve_default
                      else
                        raise ArgumentError, "missing keyword: #{fname}"
                      end

              unless f.type_valid?(value)
                expected = f.type.is_a?(Array) ? f.type.map(&:name).join(' or ') : f.type.name
                raise TypeError, "#{fname} must be #{expected}, got #{value.class}"
              end

              # Run validations
              validation_errors = f.validate_value(value)
              raise ArgumentError, validation_errors.join(', ') unless validation_errors.empty?

              instance_variable_set(:"@#{fname}", value)
            end

            freeze unless self.class._mutable
          end

          if mutable
            fields.each_key do |fname|
              attr_writer fname
            end
          end

          define_method(:to_h) do
            self.class._fields.each_with_object({}) do |(fname, _), hash|
              hash[fname] = instance_variable_get(:"@#{fname}")
            end
          end

          define_method(:to_json) do |*args|
            require 'json'
            to_h.to_json(*args)
          end

          define_singleton_method(:from_h) do |hash|
            sym_hash = hash.transform_keys(&:to_sym)
            new(**sym_hash)
          end

          define_method(:deconstruct_keys) do |keys|
            h = to_h
            keys ? h.slice(*keys) : h
          end

          define_method(:==) do |other|
            other.is_a?(self.class) && to_h == other.to_h
          end

          define_method(:hash) do
            to_h.hash
          end

          define_method(:inspect) do
            fields_str = to_h.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')
            "#<#{self.class.name || 'StructKit'} #{fields_str}>"
          end

          alias_method :to_s, :inspect
        end

        klass._fields = fields
        klass._mutable = mutable
        klass
      end
    end
  end
end
