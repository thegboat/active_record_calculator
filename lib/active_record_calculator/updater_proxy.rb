module ActiveRecordCalculator
  class UpdaterProxy
    def initialize(klass, calculator)
      @klass = klass
      @calculator = calculator
      valid_columns?
      valid_update_key?
    end
    
    def statement
      start = %{UPDATE #{update_table}
      INNER JOIN
      (#{calculator.statement}
      ) AS sub_#{subquery_table} ON sub_#{subquery_table}.#{calculator.first_group} = #{update_table}.#{calculator.update_key}
      SET\n}
      start += calculation_columns.collect do |col|
        "#{update_table}.#{col} = #{subquery_table}.#{col}"
      end.join(",\n")
      start
    end
    
    def update
      @klass.connection.update(statement)
    end
    
    private
    
    def update_table
      klass.table_name
    end
    
    def subquery_table
      calculator.table_name
    end
    
    def update_klass_columns
      @update_klass_columns ||= @klass.connection.columns(update_table).collect {|obj| obj.name.to_s}
    end
    
    def calculation_columns
      @calculation_columns ||= (calculator.columns + calculator.operation.collect(&:name))
    end
    
    def invalid_columns
      @invalid_columns ||= calculation_columns - update_klass_columns
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
      @update_key = remove_table(calculator.update_key || calculator.first_group)
      unless @update_key and update_klass_columns.include?(@update_key)
        raise NoUpdateKeyError, "No valid update key was provided for table #{update_table}"
      end
      true
    end
  end
end