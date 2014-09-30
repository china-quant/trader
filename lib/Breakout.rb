module Stocks
  # needs params[0] to be the number of days to previous to check
  class Breakout < Indicator
    def initialize(data, params = [])
      #calculate all the values for this indicator and store them
      @params = params
      @indicator_values = []
      data.each do |day|
        @indicator_values.push breakout?(day, data)
      end
    end

#    def value(dataIndex) -> return the value of the indicator at the given index

    def breakout?(day, data)
      ind = data.find_index(day)
      return -1 if ind < @params[0]

      high = 0
      low = 100000000000
      @params[0].times do |i|
        j = ind - i
        d_j = data[j]
        high = high < d_j.high ? d_j.high : high
        low = low > d_j.low ? d_j.low : low
      end

      if day.high > high
        return "breakout up"
      elsif day.low < low
        return "breakout down"
      else
        return -1
      end
    end
  end
end
