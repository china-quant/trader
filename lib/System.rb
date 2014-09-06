module Stocks
  class DailyCloseSystem
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
    
    def exit?(day, fullData)
      true
    end

    # returns R gain/loss from trade. assumes exit on close
    def exit(day, fullData, entry)
    end

    protected
  end
end
