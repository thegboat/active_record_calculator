require "active_record_calculator/version"
require "active_record_calculator/calculator_proxy"
require "active_record_calculator/operation"

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
    
    def calculator
      CalculatorProxy.new(self)
    end
  end
end

::ActiveRecord::Base.send :include, ActiveRecordCalculator
