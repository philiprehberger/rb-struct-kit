# frozen_string_literal: true

module Philiprehberger
  module StructKit
    class Field
      attr_reader :name, :type, :default, :coerce, :validations

      def initialize(name, type = nil, default: :__no_default__, coerce: nil)
        @name = name
        @type = type
        @default = default
        @coerce = coerce
        @validations = []
      end

      def has_default?
        @default != :__no_default__
      end

      def resolve_default
        return nil unless has_default?

        @default.respond_to?(:call) ? @default.call : @default
      end

      def coerce_value(value)
        return value unless @coerce

        @coerce.call(value)
      end

      def validate_type(value)
        return true if @type.nil?
        return true if value.nil? && has_default?

        value.is_a?(@type)
      end

      def add_validation(rule)
        @validations << rule
      end

      def validate_value(value)
        errors = []

        unless validate_type(value)
          errors << "#{@name} must be a #{@type}, got #{value.class}"
        end

        @validations.each do |rule|
          case rule
          when Hash
            if rule[:range] && !rule[:range].include?(value)
              errors << "#{@name} must be in range #{rule[:range]}"
            end
            if rule[:format] && !rule[:format].match?(value.to_s)
              errors << "#{@name} does not match required format"
            end
          when Proc
            msg = rule.call(value)
            errors << msg if msg.is_a?(String)
          end
        end

        errors
      end
    end
  end
end
