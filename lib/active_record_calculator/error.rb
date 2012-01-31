module ActiveRecordCalculator
  class NoUpdateKeyError < StandardError; end
  class InvalidColumnError < StandardError; end
  class UnsupportedAdapterError < StandardError; end
end