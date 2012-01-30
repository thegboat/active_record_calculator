module ActiveRecordCalculator
  class CalculatorProxy
    def initialize(klass, finder_options = {})
      @klass = klass
      @operations = []
      @columns = []
      @group_operations = []
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
      add_group_operations
      calculated_data = @klass.connection.select_all(sql)
      if @finder_options[:group]
        calculated_data.inject({}) do |all, row|
          recurse_group(all, row, groupings.dup)
        end
      else
        calculated_data
      end
    end
    
    def set_finder_options(finder_options = {})
      finder_options.symbolize_keys!
      @finder_options = finder_options.except(:select, :include, :from, :readonly, :lock)
    end
    
    def select
      s = "SELECT\n"
      s += @group_operations.collect {|op| op.build_select}.join(",\n")
      s += @columns.join(', ') + "\n"
      s += @operations.collect {|op| op.build_select(@klass)}.join(",\n")
    end
    
    private
    
    def recurse_group(hash, row, grping)
      current = grping.shift
      if grping.empty?
        hash[row[current]] ||= []
        hash[row[current]] << type_cast(row.except(current))
      else
        hash[row[current]] ||= {}
        recurse_group(hash, row.except(current), grping)
      end
      hash
    end
    
    def groupings
      @groupings ||= @group_operations.collect(&:name)
    end
    
    def type_cast(row)
      row.keys.inject({}) do |res,col|
        res[col] = if row[col] =~ /^\d+$/
           row[col].to_i
        elsif row[col] =~ /^\d+\.\d+$/
          BigDecimal(row[col])
        else
          row[col]
        end
        res
      end
    end
    
    def add_column(column_name, as)
      if as
        @columns << "#{column_name} AS #{as}"
      else  
        @columns << column_name
      end
    end
    
    def add_group_operations
      return unless @finder_options[:group]
      group_attrs = @finder_options[:group].to_s.split(',')
      group_attrs.each do |grp|
        grp.downcase!
        grp.strip!
        grp_alias = "grp_#{grp.gsub('.', '_')}"
        @group_operations << GroupOperation.new(grp, grp_alias)
      end
    end
    
    def add_operation(op, column_name, as, options)
      options = {:conditions => options} if options.is_a?(String) 
      @operations << Operation.new(op, column_name, as, options)
    end
  end
end