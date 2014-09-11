module Stocks
  class CandleSystem
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
      ind = fullData.find_index day
      if ind >= 3
        print ", #{candle(day, fullData)}"
        return candle(day, fullData) ? true : false
      else
        return false
      end
    end
    
    def entry(day, fullData)
      type = candle(day, fullData)
      ind = fullData.find_index day
      if (type.include? "rising")
        s = [fullData[ind-2].low, fullData[ind-1].low, day.low].min
        return {price: day.close, stop: s, index: ind}
      else
        s = [fullData[ind-2].high, fullData[ind-1].high, day.high].max
        return {price: day.close, stop: s, index: ind}
      end
    end
    
    # 2-day away low/high wick stop
    def exit?(day, fullData, entry)
      ind = fullData.find_index day
      stop = entry[:stop]
      if entry[:price] > entry[:stop]
        (ind - entry[:index]).times do |i|
          index = i + entry[:index] + 1
          if fullData[index].low < stop
            return true
          else
            stop = [fullData[index-2].low, fullData[index-1].low, fullData[index].low].min
          end
        end
      else
        (ind - entry[:index]).times do |i|
          index = i + entry[:index] + 1
          if fullData[index].high > stop
            return true
          else
            stop = [fullData[index-2].high, fullData[index-1].high, fullData[index].high].max
          end
        end
      end
      return false
    end

    # returns R gain/loss and percent change from trade.
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

    protected

      # using average previous candle heights, classify current candle by japanese rules
      def candle(day, fullData)
        avg_h = prev_avg_h(fullData.find_index(day), fullData)
        full_l = (day.high - day.low).abs                     # the length of the candle, wicks and all.
        body_l = (day.open - day.close).abs                   # the length of the candle body
        top_w  = (day.high - [day.close, day.open].max).abs   # the length of the top wick
        bottom_w = ([day.close, day.open].min - day.low).abs  # the length of the bottom wick

        #see if it's a Marubozu
        if ((full_l > avg_h) && (body_l > 0.8*full_l))
          return (day.open > day.close) ? "rising marubozu" : "falling marubozu"
        end

        # is it a hammer or hanging man?
        if ( (full_l > avg_h) && (top_w < body_l && body_l < bottom_w) )
          return (day.open > day.close) ? "rising hammer" : "falling hanging man"
        end

        # is it a hammer or hanging man?
        if ( (full_l > avg_h) && (top_w > body_l && body_l > bottom_w) )
          return (day.open > day.close) ? "rising inverted hammer" : "falling shooting star"
        end
        
        return false
      end

      def prev_avg_h(index, array)
        avg = 0
        index.times do |i|
          avg += (array[i].high - array[i].low ).abs
        end
        return avg/index
      end
  end
end
