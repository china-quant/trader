module Stocks
  # object container for the data of one day
  class DayData
    def initialize(open, high, low, close, volume)
      @open = open.to_f
      @high = high.to_f
      @low = low.to_f
      @close = close.to_f
      @volume = volume.to_i
    end
  end
end
