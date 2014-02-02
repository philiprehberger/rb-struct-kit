# frozen_string_literal: true

module Philiprehberger
  module StructKit
    module Validation
      def valid?
        errors.empty?
      end

      def errors
        errs = []
        self.class._fields.each do |name, field|
          value = instance_variable_get(:"@#{name}")
          errs.concat(field.validate_value(value))
        end
        errs
      end
    end
  end
end
