module ActiveRecordCalculator
  class CalculatorProxy
    def initialize(klass, finder_options = {})
      @klass = klass
      @operations = []
      @columns = []
      @finder_options = finder_options.except(:order, :select)
    end
    
    def col(column_name, as = nil)
      add_column(column_name, as)
    end
    alias :column :col
    
    def cnt(column_name, as, options = {})
      add_operation(:count, column_name, as, options)
    end
    alias :count :cnt
    
    def sum(column_name, as, options = {})
      add_operation(:sum, column_name, as, options)
    end
    
    def avg(column_name, as, options = {})
      add_operation(:avg, column_name, as, options)
    end
    alias :average :avg
    
    def max(column_name, as, options = {})
      add_operation(:max, column_name, as, options)
    end
    alias :maximum :max
    
    def min(column_name, as, options = {})
      add_operation(:min, column_name, as, options)
    end
    alias :minimum :min
    
    def calculate
      sql = @klass.send(:construct_finder_sql, @finder_options)
      sql.gsub!(/^SELECT \*/, select)
      @operations = []
      @klass.find_by_sql(sql)
    end
    
    def set_finder_options(finder_options = {})
      @finder_options = finder_options.except(:select)
    end
    
    def select
      s = "SELECT\n"
      s += @columns.join(', ') + "\n"
      s += @operations.collect {|op| op.build_select(@klass)}.join(",\n")
    end
    
    private
    
    def add_column(column_name, as)
      if as
        @columns << column_name
      else
        @columns << "#{column_name} AS #{as}"
      end
    end
    
    def add_operation(op, column_name, as, options)
      options = {:conditions => options} if options.is_a?(String) 
      @operations << Operation.new(op, column_name, as, options)
    end
  end
end