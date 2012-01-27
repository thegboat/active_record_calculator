module ActiveRecordCalculator
  class CalculatorProxy
    def initialize(klass, finder_options = {})
      @klass = klass
      @operations = []
      @finder_options = finder_options.except(:order, :select)
    end
    
    def cnt(column, as, options = {})
      add_operation(:count, column, as, options)
    end
    alias :count :cnt
    
    def sum(column, as, conditions = {})
      add_operation(:sum, column, as, options)
    end
    
    def avg(column, as, conditions = {})
      add_operation(:avg, column, as, options)
    end
    alias :average :avg
    
    def max(column, as, conditions = {})
      add_operation(:max, column, as, options)
    end
    alias :maximum :max
    
    def min(column, as, conditions = {})
      add_operation(:min, column, as, options)
    end
    alias :minimum :min
    
    def calculate
      sql = @klass.send(:construct_finder_sql, @finder_options)
      sql = gsub(/^SELECT */,build_select)
      @operations = []
      @klass.find_by_sql(sql)
    end
    
    def set_finder_options(finder_options = {})
      @finder_options = finder_options.except(:select)
    end
    
    def select
      @operations.collect {|op| op.build_select(@klass)}.join(",\n")
    end
    
    private
    
    def add_operation(op, column, as, options)
      options = {:conditions => options} if options.is_a?(String) 
      @operations << Operation.new(op, column, as, options)
    end
  end
end