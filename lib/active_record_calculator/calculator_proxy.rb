module ActiveRecordCalculator
  class CalculatorProxy
    def initialize(klass, finder_options = {})
      @klass = klass
      @operations = []
      @columns = []
      @group_operations = []
      find(finder_options)
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
    
    def table_name
      @klass.table_name
    end
    
    def columns
      @columns
    end
    
    def operations
      @operations
    end
    
    def group_operations
      @group_operations
    end
    
    def first_group
      @group_operations.first.name
    end
    
    def update_key
      @finder_options[:update_key]
    end
    
    def calculate
      result = @klass.connection.select_all(statement)
      result.collect do |row|
        @operations.each do |op|
          row[op.name] = type_cast(row[op.name])
        end
        row
      end
    end
    
    def find(finder_options = {})
      finder_options.symbolize_keys!
      @finder_options = finder_options.except(:select, :include, :from, :readonly, :lock)
    end
    
    def statement
      add_group_operations
      sql = @klass.send(:construct_finder_sql, @finder_options.except(:update_key))
      sql.gsub(/^SELECT\s+\*/i, select)
    end
    
    private
    
    def select
      s = []
      s += @group_operations.collect {|op| op.build_select}
      s += @columns.collect {|col| op.build_select}
      s += @operations.collect {|op| op.build_select(@klass)}
      "SELECT " + s.join(",\n")
    end
    
    def groupings
      @groupings ||= @group_operations.collect(&:name)
    end
    
    def type_cast(data)
      if data =~ /^\d+$/
        data.to_i
      elsif data =~ /^\d+\.\d+$/
        BigDecimal(data)
      else
        data
      end
    end
    
    def add_column(column_name, as) 
      @columns << Column.new(column_name,as)
    end
    
    def add_group_operations
      @group_operations = []
      return unless @finder_options[:group]
      group_attrs = @finder_options[:group].to_s.split(',')
      if @finder_options[:for_update]
        @finder_options[:group] = group_attrs.first
        group_attrs = [group_attrs.first]
      end
      group_attrs.each do |grp|
        grp.downcase!
        grp.strip!
        grp_alias = "grp_#{grp.gsub('.', '_')}"
        @group_operations << GroupOperation.new(grp, grp_alias)
      end
      @group_operations.uniq!
    end
    
    def add_operation(op, column_name, as, options)
      options = {:conditions => options} if options.is_a?(String) 
      @operations << Operation.new(op, column_name, as, options)
    end
  end
end