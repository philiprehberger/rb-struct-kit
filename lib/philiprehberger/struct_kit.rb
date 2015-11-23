# frozen_string_literal: true

require_relative 'struct_kit/version'
require_relative 'struct_kit/field'
require_relative 'struct_kit/definition'

module Philiprehberger
  module StructKit
    def self.define(mutable: false, &block)
      defn = Definition.new(mutable: mutable)
      defn.instance_eval(&block)
      defn.build
    end
  end
end
