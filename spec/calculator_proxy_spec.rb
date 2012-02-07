require 'spec_helper'

describe ActiveRecordCalculator::CalculatorProxy do
  describe  "#new" do
    it "should return a ActiveRecordCalculator::CalculatorProxy instance" do
      instance = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      instance.class.to_s.should eq('ActiveRecordCalculator::CalculatorProxy')
    end
  end

  describe "#col, #column" do
    it "should add a ActiveRecordCalculator::Column instance to columns" do
      instance = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      instance.col(:id)
      instance.column(:id)
      instance.columns.length.should eq(2)
      instance.columns.first.class.should eq(ActiveRecordCalculator::Column)
    end
  end

  describe "#count, #cnt" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      instance = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      instance.count(:id, 'counter')
      instance.cnt(:id, 'counter2')
      instance.operations.length.should eq(2)
      instance.operations.first.op.should eq(:count)
      instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end

  describe "#max, #maximum" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      instance = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      instance.max(:id, 'counter')
      instance.maximum(:id, 'counter2')
      instance.operations.length.should eq(2)
      instance.operations.first.op.should eq(:max)
      instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end

  describe "#min, #minimum" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      instance = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      instance.min(:id, 'counter')
      instance.minimum(:id, 'counter2')
      instance.operations.length.should eq(2)
      instance.operations.first.op.should eq(:min)
      instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end

  describe "#avg, #average" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      instance = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      instance.avg(:id, 'counter')
      instance.average(:id, 'counter2')
      instance.operations.length.should eq(2)
      instance.operations.first.op.should eq(:avg)
      instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end

  describe "#sum" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      instance = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      instance.sum(:id, 'counter')
      instance.operations.length.should eq(1)
      instance.operations.first.op.should eq(:sum)
      instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end
  
  describe "#calculate" do
    it "should calculate as base aggregate methods" do
      instance = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      instance.count(:id, :total_purchases)
      instance.count(:id, :expensive_purchases, "amount_in_cents > 100")
      instance.avg(:amount_in_cents, :cost_per_purchase)
      instance.avg(:amount_in_cents, :cost_per_expensive_purchase, "amount_in_cents > 100")
      instance.sum(:amount_in_cents, :total_sales)
      instance.sum(:amount_in_cents, :total_expensive_sales, "amount_in_cents > 100")
      instance.min(:amount_in_cents, :least_over_100, "amount_in_cents > 100")
      instance.max(:amount_in_cents, :most_less_100, "amount_in_cents <= 100")
      rtn = instance.calculate.first
      rtn['total_purchases'].should eq(Purchase.count)
      rtn['expensive_purchases'].should eq(Purchase.count(:id, :conditions => "amount_in_cents > 100"))
      rtn['cost_per_purchase'].should eq(Purchase.average(:amount_in_cents))
      rtn['cost_per_expensive_purchase'].should eq(Purchase.average(:amount_in_cents, :conditions => "amount_in_cents > 100"))
      rtn['total_sales'].should eq(Purchase.sum(:amount_in_cents))
      rtn['total_expensive_sales'].should eq(Purchase.sum(:amount_in_cents, :conditions => "amount_in_cents > 100"))
      rtn['least_over_100'].should eq(Purchase.minimum(:amount_in_cents, :conditions => "amount_in_cents > 100"))
      rtn['most_less_100'].should eq(Purchase.maximum(:amount_in_cents, :conditions => "amount_in_cents <= 100"))
    end
  end
end