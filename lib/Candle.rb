module Stocks
  class Candle < Indicator
    def initialize(data, params = [])
      #calculate all the values for this indicator and store them
      @params = params
      @indicator_values = []
      data.each do |day|
        @indicator_values.push candle(day, data)
      end
    end

#    def value(dataIndex) -> return the value of the indicator at the given index

    # using average previous candle heights, classify current candle by japanese rules
    def candle(day, fullData)
#     avg_h = prev_avg_h(fullData.find_index(day), fullData)
      full_l = (day.high - day.low).abs                     # the length of the candle, wicks and all.
      body_l = (day.open - day.close).abs                   # the length of the candle body
      top_w  = (day.high - [day.close, day.open].max).abs   # the length of the top wick
      bottom_w = ([day.close, day.open].min - day.low).abs  # the length of the bottom wick

      candle_str = day.close > day.open ? "rising " : "falling "

      #see if it's a Marubozu
      if (body_l > 0.8*full_l)
        candle_str += "marubozu"
      # is it a hammer?
      elsif (top_w < body_l && body_l < bottom_w)
        candle_str += "hammer"
      # is it a shooting star?
      elsif (top_w > body_l && body_l > bottom_w)
        candle_str += "shooting star"
      elsif (top_w > body_l && bottom_w > body_l)
        candle_str += "top"
      end
      
      return candle_str
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
