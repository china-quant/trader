module Stocks
  # this system is simply:
    # enter: after one day in the opposite market direction (Bull/Bear), buying in a Bull and shorting in a Bear
    # exit: on one day in the opposite direction
    # all actions occur at close, preventing day-trader shit from coming into play
  # it's a contrarian entry system that exits on weakness
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
      ind = fullData.find_index(day)
      if ind != 0
        if @params[:bull] == true
          return day.close < fullData[ind-1].close #if we're down in an up-market, buy
        else
          return day.close > fullData[ind-1].close #if we're up in a down-market, short
        end
      end
      false
    end
    
    def entry(day, fullData)
      if @params[:bull] == true
        return {price: day.close, stop: day.close - (day.close*0.02)}
      else
        return {price: day.close, stop: day.close + (day.close*0.02)}
      end
    end
    
    def exit?(day, fullData)
      ind = fullData.find_index(day)
      if ind != 0
        if @params[:bull] == true
          return day.close < fullData[ind-1].close #if we're down in an up-market, close
        else
          return day.close > fullData[ind-1].close #if we're up in a down-market, close
        end
      end
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
