require_relative 'Indicator'
module Stocks
  class ATR < Indicator
    def initialize(data, params = [])
      #calculate all the values for this indicator and store them
      @atr_param = params[0]
      @indicator_values = []
      data.each do |day|
        @indicator_values.push calc_atr(day, data, @atr_param)
      end
    end

    protected

      def calc_atr(day, fullData, atr_param)
        ind = fullData.find_index(day)
        return -1 if ind < atr_param

        tr = [
          (day.high - day.low),
          (day.high - fullData[ind-1].close).abs,
          (day.low - fullData[ind-1].close).abs
        ].max
        atr = tr
        atr_param.times do |index|
          if ind - index >= 0 && index > 0
            d_i = ind - index
            d2  = fullData[d_i]
            tr1 = [
              (d2.high - d2.low),
              (d2.high - fullData[d_i-1].close).abs,
              (d2.low - fullData[d_i-1].close).abs
            ].max
            atr = ((atr*index) + tr1) / (index+1)
          end
        end

        return atr
      end
  end
end
