require_relative 'DayData'

module Stocks
  # the end date is always the present
  class DataGetter2
    def initialize(start_date, ticker)
      @start_date = start_date
      @ticker = ticker
      self.get_raw
    end

    def get_raw
    @raw = []
      f = File.open(@ticker+".csv", "r")
      f.each_line do |line|
        @raw.push line.split(/[,\n]/)[0]
        @raw.push line.split(/[,\n]/)[1]
        @raw.push line.split(/[,\n]/)[2]
        @raw.push line.split(/[,\n]/)[3]
        @raw.push line.split(/[,\n]/)[4]
        @raw.push line.split(/[,\n]/)[5]
      end
      f.close
    end

    def raw
      @raw
    end

    def by_day
      result = []
      rc = @raw
      rc = rc.drop(6) # removes the headers
      (rc.count/6).times do |i|
        b = i*6
        result.push(
          DayData.new(rc[b], rc[b+1], rc[b+2], rc[b+3], rc[b+4], rc[b+5])
        )
      end
      @candles = result.reverse
      return @candles
    end

    def candles
      @candles
    end
  end
end
