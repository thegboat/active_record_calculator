require 'spec_helper'

describe ActiveRecordCalculator::CalculatorProxy, "#new" do
  it "should return a ActiveRecordCalculator::CalculatorProxy instance" do
    instance = ActiveRecordCalculator::CalculatorProxy.new(FakeClass)
    instance.class.to_s.should eq('ActiveRecordCalculator::CalculatorProxy')
  end
end

describe ActiveRecordCalculator::CalculatorProxy, "#col, #column" do
  it "should add a ActiveRecordCalculator::Column instance to columns" do
    instance = ActiveRecordCalculator::CalculatorProxy.new(FakeClass)
    instance.col(:id)
    instance.column(:id)
    instance.columns.length.should eq(2)
    instance.columns.first.class.should eq(ActiveRecordCalculator::Column)
  end
end

describe ActiveRecordCalculator::CalculatorProxy, "#count, #cnt" do
  it "should add a ActiveRecordCalculator::Operation instance to operations" do
    instance = ActiveRecordCalculator::CalculatorProxy.new(FakeClass)
    instance.count(:id, 'counter')
    instance.cnt(:id, 'counter2')
    instance.operations.length.should eq(2)
    instance.operations.first.op.should eq(:count)
    instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
  end
end

describe ActiveRecordCalculator::CalculatorProxy, "#max, #maximum" do
  it "should add a ActiveRecordCalculator::Operation instance to operations" do
    instance = ActiveRecordCalculator::CalculatorProxy.new(FakeClass)
    instance.max(:id, 'counter')
    instance.maximum(:id, 'counter2')
    instance.operations.length.should eq(2)
    instance.operations.first.op.should eq(:max)
    instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
  end
end

describe ActiveRecordCalculator::CalculatorProxy, "#min, #minimum" do
  it "should add a ActiveRecordCalculator::Operation instance to operations" do
    instance = ActiveRecordCalculator::CalculatorProxy.new(FakeClass)
    instance.min(:id, 'counter')
    instance.minimum(:id, 'counter2')
    instance.operations.length.should eq(2)
    instance.operations.first.op.should eq(:min)
    instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
  end
end

describe ActiveRecordCalculator::CalculatorProxy, "#avg, #average" do
  it "should add a ActiveRecordCalculator::Operation instance to operations" do
    instance = ActiveRecordCalculator::CalculatorProxy.new(FakeClass)
    instance.avg(:id, 'counter')
    instance.average(:id, 'counter2')
    instance.operations.length.should eq(2)
    instance.operations.first.op.should eq(:avg)
    instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
  end
end

describe ActiveRecordCalculator::CalculatorProxy, "#sum" do
  it "should add a ActiveRecordCalculator::Operation instance to operations" do
    instance = ActiveRecordCalculator::CalculatorProxy.new(FakeClass)
    instance.sum(:id, 'counter')
    instance.operations.length.should eq(1)
    instance.operations.first.op.should eq(:sum)
    instance.operations.first.class.should eq(ActiveRecordCalculator::Operation)
  end
end