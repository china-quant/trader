module Stocks
  class System
    def initialize(params = {})
      @params = params
    end

    def params=(new_params)
      @params = new_params
    end

    def params
      @params
    end

    def enter?(day, fullData)
      false
    end
    
    def entry(day, fullData)
    end
    
    def exit?(day, fullData, entry)
      true
    end

    # returns R gain/loss from trade. assumes exit on close
    def exit(day, fullData, entry)
      if entry[:price] > entry[:stop]  #was a buy trade
        return {
                 r: (day.close - entry[:price]) / (entry[:price] - entry[:stop]),
                 percent: (day.close - entry[:price]) / entry[:price]
               }
      else  # was a short sale trade
        return {
                 r: (entry[:price] - day.close) / (entry[:stop] - entry[:price]),
                 percent: (entry[:price] - day.close) / entry[:price]
               }
      end
    end

  end
end
