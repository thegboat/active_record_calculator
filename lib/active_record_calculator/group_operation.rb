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
      @column
    end
    
    def name
      @as
    end
  end
end