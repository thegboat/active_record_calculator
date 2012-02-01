require 'spec_helper'

describe ActiveRecordCalculator::Column, "#new" do
  it "should return a ActiveRecordCalculator::Column instance" do
    instance = ActiveRecordCalculator::Column.new('a_column', nil)
    instance.class.should eq(ActiveRecordCalculator::Column)
  end
end

describe ActiveRecordCalculator::Column, "#inpsect" do
  it "should return a column name" do
    instance = ActiveRecordCalculator::Column.new('a_column', nil)
    instance.inspect.should eq('a_column')
  end
end

describe ActiveRecordCalculator::Column, "#alias" do
  it "should return given alias" do
    instance = ActiveRecordCalculator::Column.new('a_column', 'an_alias')
    instance.alias_name.should eq('an_alias')
  end
end

describe ActiveRecordCalculator::Column, "#build_select" do
  it "should return correct name/alias" do
    instance = ActiveRecordCalculator::Column.new('a_column', 'an_alias')
    instance.build_select.should eq('a_column AS an_alias')
  end
  
  it "should return correct name/name when no alias given" do
    instance = ActiveRecordCalculator::Column.new('a_column', nil)
    instance.build_select.should eq('a_column AS a_column')
  end
end
