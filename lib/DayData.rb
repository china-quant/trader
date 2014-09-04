require 'date'

module Stocks
  # object container for the data of one day
  class DayData
    def initialize(datestr, open, high, low, close, volume)
      @datestr = datestr
      @open = open.to_f
      @high = high.to_f
      @low = low.to_f
      @close = close.to_f
      @volume = volume.to_i
    end

    def to_s
      "Date: #{@datestr}, close: #{@close}"
    end

    def date
      Date.parse(@datestr)
    end

    def open
      @open
    end

    def close
      @close
    end

    def high
      @high
    end

    def low
      @low
    end

    def volume
      @volume.to_i
    end

    def ==(o)
      o.class == self.class && o.state == state
    end
    alias_method :eql?, :==

    protected

      def state
        [@open, @high, @low, @close, @volume, @datestr]
      end
  end
end
