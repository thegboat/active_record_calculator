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
      start = %{UPDATE #{table}
      INNER JOIN
      (#{calculator.statement}
      ) AS sub_#{subquery_table} ON sub_#{subquery_table}.group_column_1 = #{table}.#{key}
      SET\n}
      start += calculation_columns.collect do |col|
        "#{table}.#{col} = sub_#{subquery_table}.#{col}"
      end.join(",\n")
      start
    end
    
    private
    
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
      calculator.table_name
    end
    
    def update_columns
      @update_columns ||= connection.columns(table).collect {|obj| obj.name.to_s}
    end
    
    def calculation_columns
      @calculation_columns ||= (calculator.columns + calculator.operations.collect(&:name))
    end
    
    def invalid_columns
      @invalid_columns ||= calculation_columns - update_columns
    end
    
    def invalid_columns_sentence
      start = invalid_columns[0..-2].join(', ')
      if invalid_columns.length > 1
        start += ' and ' + invalid_columns[-1..-1].to_s
      end
      start
    end
    
    def valid_columns?
      raise InvalidColumnError, "Can not resolve update column(s) #{invalid_columns.to_sentence} for table #{update_table}" unless invalid_columns.empty?
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