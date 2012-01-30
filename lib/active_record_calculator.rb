require 'active_record'
require "active_record_calculator/version"
require "active_record_calculator/calculator_proxy"
require "active_record_calculator/operation"
require "bigdecimal"

module ActiveRecordCalculator
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def calculate_many(options = {}, &blk)
      calculator = CalculatorProxy.new(self, options)
      yield calculator
      calculator.calculate
    end
    
    def update_many(update_klass, options = {}, &blk)
      options.merge!(:for_update => true)
      calculator = CalculatorProxy.new(self, options)
      yield calculator
      updater = UpdaterProxy.new(update_klass,calculator)
      updater.update
    end
    
    def new_calculator
      CalculatorProxy.new(self)
    end
  end
end

::ActiveRecord::Base.send :include, ActiveRecordCalculator
