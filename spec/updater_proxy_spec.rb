require 'spec_helper'

describe ActiveRecordCalculator::UpdaterProxy do
  describe  "#new" do
    it "should raise exception if no group on calculator" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      lambda { 
        ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator) 
      }.should raise_error(ActiveRecordCalculator::NoUpdateKeyError)
    end
    
    it "should raise exception if there is an alias for the calculator that does not match the updater" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase)
      calculator.count(:id, :not_existent_column)
      lambda { 
        ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator) 
      }.should raise_error(ActiveRecordCalculator::InvalidColumnError)
    end
    
    it "should return a ActiveRecordCalculator::UpdaterProxy instance" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase, {:group => "purchases.store_id"})
      instance = ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator)
      instance.class.to_s.should eq('ActiveRecordCalculator::UpdaterProxy')
    end
  end

  describe "#col, #column" do
    it "should add a ActiveRecordCalculator::Column instance to columns" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase, {:group => "purchases.store_id"})
      instance = ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator)
      instance.col(:id)
      instance.column(:id)
      instance.send(:calculator).columns.length.should eq(2)
      instance.send(:calculator).columns.first.class.should eq(ActiveRecordCalculator::Column)
    end
  end

  describe "#count, #cnt" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase, {:group => "purchases.store_id"})
      instance = ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator)
      instance.count(:id, 'counter')
      instance.cnt(:id, 'counter2')
      instance.send(:calculator).operations.length.should eq(2)
      instance.send(:calculator).operations.first.op.should eq(:count)
      instance.send(:calculator).operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end

  describe "#max, #maximum" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase, {:group => "purchases.store_id"})
      instance = ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator)
      instance.max(:id, 'counter')
      instance.maximum(:id, 'counter2')
      instance.send(:calculator).operations.length.should eq(2)
      instance.send(:calculator).operations.first.op.should eq(:max)
      instance.send(:calculator).operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end

  describe "#min, #minimum" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase, {:group => "purchases.store_id"})
      instance = ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator)
      instance.min(:id, 'counter')
      instance.minimum(:id, 'counter2')
      instance.send(:calculator).operations.length.should eq(2)
      instance.send(:calculator).operations.first.op.should eq(:min)
      instance.send(:calculator).operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end

  describe "#avg, #average" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase, {:group => "purchases.store_id"})
      instance = ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator)
      instance.avg(:id, 'counter')
      instance.average(:id, 'counter2')
      instance.send(:calculator).operations.length.should eq(2)
      instance.send(:calculator).operations.first.op.should eq(:avg)
      instance.send(:calculator).operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end

  describe "#sum" do
    it "should add a ActiveRecordCalculator::Operation instance to operations" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase, {:group => "purchases.store_id"})
      instance = ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator)
      instance.sum(:id, 'counter')
      instance.send(:calculator).operations.length.should eq(1)
      instance.send(:calculator).operations.first.op.should eq(:sum)
      instance.send(:calculator).operations.first.class.should eq(ActiveRecordCalculator::Operation)
    end
  end
  
  describe "#update" do
    it "should update the specified table" do
      calculator = ActiveRecordCalculator::CalculatorProxy.new(Purchase, {:group => "purchases.store_id"})
      instance = ActiveRecordCalculator::UpdaterProxy.new(:stat_summaries, :store_id, calculator)
      instance.count(:id, :total_purchases)
      instance.avg(:amount_in_cents, :cost_per_purchase)
      instance.sum(:amount_in_cents, :total_sales)
      instance.count(:id, :purchases_with_coupon, "used_coupon = true")
      instance.update
      StatSummary.all.each do |stat_summary|
        stat_summary.total_purchases.should eq(Purchase.count(:id, :conditions => {:store_id => stat_summary.store_id}))
        stat_summary.cost_per_purchase.round(2).should eq(Purchase.average(:amount_in_cents, :conditions => {:store_id => stat_summary.store_id}).round(2))
        stat_summary.total_sales.should eq(Purchase.sum(:amount_in_cents, :conditions => {:store_id => stat_summary.store_id}))
        stat_summary.purchases_with_coupon.should eq(Purchase.count(:id, :conditions => {:store_id => stat_summary.store_id, :used_coupon => true}))
      end
    end
  end
end