require_relative 'Indicator'
module Stocks
  class SimpleMovingAverage < Indicator
    def initialize(data, params = [])
      #calculate all the values for this indicator and store them
      @sma_param = params[0]
      @indicator_values = []
      data.each do |day|
        @indicator_values.push calc_sma(day, data, @sma_param)
      end
    end

#    def value(dataIndex) -> return the value of the indicator at the given index
    protected

      def calc_sma(day, fullData, sma_param)
        ind = fullData.find_index(day)
        return -1 if ind < sma_param

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
