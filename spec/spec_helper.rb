require 'rubygems'
require 'bundler/setup'

require 'active_record_calculator'

class FakeConnection
end

class FakeClass
  
  def table_name
    "some_records"
  end
  
end

RSpec.configure do |config|
  # some (optional) config here
end