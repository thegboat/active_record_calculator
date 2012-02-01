module ActiveRecordCalculator
  class Operation
    
    def initialize(op, column, as, options)
      @op = op
      @column = column
      @as = as
      @options = options
    end
    
    def build_select(klass)
      mock = klass.send(:construct_calculation_sql, @op, @column, @options)
      all, sel, cond = if mock =~ /\s+WHERE\s+/
        mock.match(/^SELECT\s+(.*)\s+AS.*\s+WHERE\s?(.*)/).to_a
      else  
        mock.match(/^SELECT\s+(.*)\s+AS/).to_a
      end
      return "#{sel} AS #{@as}" unless cond
      i = sel.index('(')
      start = sel[0..i]
      mid = "CASE #{cond} WHEN 1 THEN #{sel[i+1..-2]} ELSE #{default} END"
      fin = ") AS #{@as}"
      "#{start}#{mid}#{fin}"
    end
    
    def inspect
      "#{@as} => #{@op}"
    end
    
    def name
      @as.to_s
    end
    
    def op
      @op
    end
    
    private
    
    def default
      @op == :sum ? 0 : 'NULL'
    end
  end
end