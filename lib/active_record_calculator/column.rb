module ActiveRecordCalculator
  class Column
    
    def initialize(name, as)
      @name = name
      @as = as
    end
    
    def build_select
      "#{@name} AS #{@as || @name}"
    end
    
    def inspect
      @name.to_s
    end
    
    def alias_name
      @as.to_s
    end
  end
end