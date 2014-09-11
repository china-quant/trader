module Stocks
  # allows for testing a variety of SMA systems
    # configurable sma-length
  class SMASystem
    def initialize(params = {})
      @params = params
      @sma = {}
    end

    def params=(new_params)
      @params = new_params
    end

    def params
      @params
    end

    def sma(day, fullData, sma_param)
      if @sma[sma_param] == nil
        @sma[sma_param] = []
        fullData.each do |data|
          @sma[sma_param].push calc_sma(data, fullData, sma_param)
        end
      end
      ind = fullData.find_index(day)
      return @sma[sma_param][ind]
    end

    def enter?(day, fullData)
      if @params[:num_avgs] == 1 # price/sma crossover system
        ind = fullData.find_index(day)
        if ind >= @params[:first_sma]
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
        return {price: day.close, stop: day.close - (day.close*0.02), d_index: ind}
      else
        return {price: day.close, stop: day.close + (day.close*0.02), d_index: ind}
      end
    end
    
    def exit?(day, fullData, entry)
      ind = fullData.find_index(day)
      if entry[:price] > entry[:stop]  #was a buy trade
        if day.low <= entry[:stop]
          return true          
        end
        avg = self.sma(day, fullData, @params[:first_sma])
        old_avg = self.sma(fullData[ind-1], fullData, @params[:first_sma])
        return crossDown?(avg, day, old_avg, fullData[ind-1])
      else  # was a short sale trade
        if day.high >= entry[:stop]
          return true          
        end
        avg = self.sma(day, fullData, @params[:first_sma])
        old_avg = self.sma(fullData[ind-1], fullData, @params[:first_sma])
        return crossUp?(avg, day, old_avg, fullData[ind-1])
      end
    end

    # returns R gain/loss from trade. assumes exit on close
    def exit(day, fullData, entry)
      ind = fullData.find_index(day)
      if entry[:price] > entry[:stop]  #was a buy trade
        (ind - entry[:d_index]).times do |i|
          if fullData[entry[:d_index]+i+1].low <= entry[:stop]
            return { r: -1,
                     percent: (entry[:stop] - entry[:price]) / entry[:price] }
          end
        end
        return {
                 r: (day.close - entry[:price]) / (entry[:price] - entry[:stop]),
                 percent: (day.close - entry[:price]) / entry[:price]
               }
      else  # was a short sale trade
        (ind - entry[:d_index]).times do |i|
          if fullData[entry[:d_index]+i+1].high >= entry[:stop]
            return { r: -1,
                     percent: (entry[:price] - entry[:stop]) / entry[:price] }
          end
        end
        return {
                 r: (entry[:price] - day.close) / (entry[:stop] - entry[:price]),
                 percent: (entry[:price] - day.close) / entry[:price]
               }
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

      def calc_sma(day, fullData, sma_param)
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
  end
end
