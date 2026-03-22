# frozen_string_literal: true

module Philiprehberger
  module StructKit
    class Field
      UNSET = Object.new.freeze

      attr_reader :name, :type, :validations

      def initialize(name, type = nil, default: UNSET)
        @name = name
        @type = type
        @default = default
        @validations = []
      end

      def has_default?
        @default != UNSET
      end

      def resolve_default
        @default.respond_to?(:call) ? @default.call : @default
      end

      def type_valid?(value)
        return true if @type.nil?

        if @type.is_a?(Array)
          @type.any? { |t| value.is_a?(t) }
        else
          value.is_a?(@type)
        end
      end

      def add_validation(rule)
        @validations << rule
      end

      def validate_value(value)
        errors = []

        @validations.each do |rule|
          case rule
          when Hash
            errors << "#{@name} must be in range #{rule[:range]}" if rule[:range] && !rule[:range].include?(value)
            errors << "#{@name} does not match required format" if rule[:format] && !rule[:format].match?(value.to_s)
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
