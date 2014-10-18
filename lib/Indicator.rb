module Stocks
  class Indicator
    def initialize(data, params = [])
      #calculate all the values for this indicator and store them
    end

    def data=(data)
      @data = data
    end

    def value(dataIndex)
      #return the value of the indicator at the given index
      @indicator_values[dataIndex]
    end

    def to_s
      s = ""
      @indicator_values.each do |i|
        s += "#{i}\n"
      end
    end
  end
end
