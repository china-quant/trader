require_relative 'Indicator'
module Stocks
  class FiveDD < Indicator
    def initialize(data, params = [])
      #calculate all the values for this indicator and store them
      @params = params
      @indicator_values = []
      data.each do |day|
        @indicator_values.push fivedd?(day, data)
      end
    end

#    def value(dataIndex) -> return the value of the indicator at the given index

    def fivedd?(day, data)
      ind = data.find_index(day)
      return false if ind < 4

      all_down = true
      5.times do |i|
        j = ind - i
        k = ind - (i+1)
        all_down = false unless data[j].close < data[k].close
      end

      if all_down
        return true
      else
        return false
      end
    end
  end
end
