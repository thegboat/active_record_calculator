module ActiveRecordCalculator
  class GroupOperation
    
    def initialize(column, as)
      @column = column
      @as = as
    end
    
    def build_select
      "#{@column} AS #{@as}"
    end
    
    def inspect
      @column.to_s
    end
    
    def name
      @as.to_s
    end
  end
end