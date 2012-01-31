require 'active_record'
require "active_record_calculator/version"
require "active_record_calculator/calculator_proxy"
require "active_record_calculator/updater_proxy"
require "active_record_calculator/operation"
require "active_record_calculator/group_operation"
require "active_record_calculator/column"
require "active_record_calculator/error"
require "bigdecimal"

module ActiveRecordCalculator
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def calculator(options = {}, &blk)
      c = CalculatorProxy.new(self, options)
      yield c if blk
      c
    end
  end
end

::ActiveRecord::Base.send :include, ActiveRecordCalculator
