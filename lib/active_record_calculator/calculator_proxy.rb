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
    
    def table
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
    
    def update_key
      @group_operations.first ? @group_operations.first.name : nil
    end
    
    def calculate
      result = select_all(statement)
      result.collect do |row|
        @operations.each do |op|
          row[op.name] = type_cast(row[op.name])
        end
        row
      end
    end
    
    def connection
      @klass.connection
    end
    
    def select_all(query)
      connection.select_all(query)
    end
    
    def find(finder_options = {})
      finder_options.symbolize_keys!
      @finder_options = finder_options.except(:select, :include, :from, :readonly, :lock)
    end
    
    def statement
      add_group_operations
      construct_finder_sql.gsub(/^SELECT\s+\*/i, select)
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
      group_attrs.each_with_index do |grp, i|
        grp.downcase!
        grp.strip!
        grp_alias = "group_column_#{i+1}"
        @group_operations << GroupOperation.new(grp, grp_alias)
      end
      @group_operations.uniq!
    end
    
    def add_operation(op, column_name, as, options)
      options = {:conditions => options} if options.is_a?(String) 
      @operations << Operation.new(op, column_name, as, options)
    end
    
    def construct_finder_sql
      @klass.send(:construct_finder_sql, @finder_options)
    end
    
    # def sanitized_finder_params
    #   @finder_options[:conditions] = sanitize_sql_for_conditions(@finder_options[:conditions]) if @finder_options[:conditions]
    #   @finder_options[:group] = sanitize_sql(@finder_options[:group]) if @finder_options[:group]
    #   @finder_options[:having] = sanitize_sql(@finder_options[:having]) if @finder_options[:having]
    # end
    
    def sanitize_sql(ary)
      ActiveRecord::Base.sanitize_sql(ary, table)
    end
    
    def sanitize_sql_for_conditions(condition)
      ActiveRecord::Base.sanitize_sql_for_conditions(condition, table)
    end
  end
end