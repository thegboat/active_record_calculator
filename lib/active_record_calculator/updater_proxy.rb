module ActiveRecordCalculator
  class UpdaterProxy
    def initialize(table, foreign_key, calculator_proxy)
      @table = table
      set_calculator(calculator_proxy)
      @key = foreign_key
      valid_columns?
      valid_update_key?
    end
    
    def statement
      case connection.adapter_name
      when /mysql/i then mysql_statement
      when /postgresql/i then psql_statement
      else abstract_statement
      end
    end
    
    def update
      connection.update(statement)
    end
    
    def col(column_name, as = nil)
      calculator.col(column_name, as)
    end
    alias :column :col
    
    def cnt(column_name, as, options = {})
      calculator.count(column_name, as, options)
    end
    alias :count :cnt
    
    def sum(column_name, as, options = {})
      calculator.sum(column_name, as, options)
    end
    
    def avg(column_name, as, options = {})
      calculator.avg(column_name, as, options)
    end
    alias :average :avg
    
    def max(column_name, as, options = {})
      calculator.max(column_name, as, options)
    end
    alias :maximum :max
    
    def min(column_name, as, options = {})
      calculator.min(column_name, as, options)
    end
    alias :minimum :min
    
    private
    
    def mysql_statement
      sql = %{UPDATE #{table}
      INNER JOIN
      (#{calculator.statement}
      ) AS sub_#{subquery_table} ON sub_#{subquery_table}.group_column_1 = #{table}.#{key}
      SET\n}
      sql += calculation_columns.collect do |col|
        "#{table}.#{col} = sub_#{subquery_table}.#{col}"
      end.join(",\n")
      sql
    end
    
    def psql_statement
      abstract_statement.gsub(/^UPDATE/, "UPDATE ONLY")
    end
    
    def abstract_statement
      sql = "UPDATE #{table} SET\n"
      sql += calculation_columns.collect do |col|
        "#{table}.#{col} = sub_#{subquery_table}.#{col}"
      end.join(",\n")
      sql += "\nFROM #{table}, (#{calculator.statement}) AS sub_#{subquery_table}\n"
      sql += "WHERE sub_#{subquery_table}.group_column_1 = #{table}.#{key}"
      sql
    end
    
    def connection
      calculator.connection
    end
    
    def calculator
      @calculator
    end
    
    def key
      "#{remove_table(@key)}"
    end
    
    def set_calculator(calculator_proxy)
      calculator_proxy.send(:add_group_operations)
      @calculator = calculator_proxy
    end
    
    def table
      @table
    end
    
    def subquery_table
      calculator.table
    end
    
    def update_columns
      @update_columns ||= connection.columns(table).collect {|obj| obj.name.to_s}
    end
    
    def calculation_columns
      calculator.columns.collect(&:alias_name) + calculator.operations.collect(&:name)
    end
    
    def invalid_columns
      calculation_columns - update_columns
    end
    
    def invalid_columns_sentence
      case invalid_columns.length
      when 0
        ""
      when 1
        invalid_columns[0].to_s
      when 2
        "#{invalid_columns[0]} and #{invalid_columns[1]}"
      else
        "#{invalid_columns[0...-1].join(', ')} and #{invalid_columns[-1]}"
      end
    end
    
    def valid_columns?
      raise InvalidColumnError, "Can not resolve update column(s) #{invalid_columns_sentence} for table #{table}" unless invalid_columns.empty?
      true
    end
    
    def remove_table(s)
      s.to_s.split('.').last
    end
    
    def valid_update_key?
      unless calculator.update_key
        raise NoUpdateKeyError, "No valid update key was provided for table #{subquery_table}"
      end
      true
    end
  end
end