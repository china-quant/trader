module Stocks
  class SMASystem
    def initialize(params = {})
      @params = params
    end

    def params=(new_params)
      @params = new_params
    end

    def params
      @params
    end

    def sma(day, fullData, sma_param)
      return day.close if sma_param == 0
      ind = fullData.find_index(day)
      avg = day.close
      sma_param.times do |index|
        if ind - index >= 0 && index > 0
          avg = ((avg*index) + fullData[ind-index].close) / (index+1)
        end
      end

      return avg
    end

    def enter?(day, fullData)
      if @params[:num_avgs] == 1 # price/sma crossover system
        ind = fullData.find_index(day)
        if ind != 0
          if crossover?(day, fullData[ind-1], fullData)
            return true
          else
            return false
          end
        else
          return false
        end
      else
        return false
      end
    end
    
    def entry(day, fullData)
      ind = fullData.find_index(day)
      avg = self.sma(day, fullData, @params[:first_sma])
      old_avg = self.sma(fullData[ind-1], fullData, @params[:first_sma])
      if crossUp?(avg, day, old_avg, fullData[ind-1])
        return {price: day.close, stop: day.close - (day.close*0.02)}
      else
        return {price: day.close, stop: day.close + (day.close*0.02)}
      end
    end
    
    def exit?(day, fullData)
      true
    end

    # returns R gain/loss from trade. assumes exit on close
    def exit(day, fullData, entry)
      if entry[:price] > entry[:stop]  #was a buy trade
        return (day.close - entry[:price]) / (entry[:price] - entry[:stop])
      else  # was a short sale trade
        return (entry[:price] - day.close) / (entry[:stop] - entry[:price])
      end
    end

    protected
      def crossover?(day1, day2, fullData)
        avg = self.sma(day1, fullData, @params[:first_sma])
        old_avg = self.sma(day2, fullData, @params[:first_sma])

        return crossUp?(avg, day1, old_avg, day2) ||
               crossDown?(avg, day1, old_avg, day2)
      end

      def crossDown?(avg1, day1, avg2, day2)
        return (avg1 > day1.close && avg2 <= day2.close)
      end

      def crossUp?(avg1, day1, avg2, day2)
        return (avg1 < day1.close && avg2 >= day2.close)
      end
  end
end
