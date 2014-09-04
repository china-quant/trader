require_relative 'DayData'

module Stocks
  # the end date is always the present
  class DataGetter
    SOURCE = "ichart.yahoo.com"

    def initialize(start_date, ticker)
      @start_date = start_date
      @ticker = ticker
      self.get_raw
    end

    def get_raw
      day = @start_date.day
      mnth = @start_date.month - 1
      yr = @start_date.year
      day2 = Date.today.day
      mnth2 = Date.today.month - 1
      yr2 = Date.today.year
      Net::HTTP.start(SOURCE) do |http|
        resp = http.get("/table.csv?s=#{@ticker}&a=#{mnth}&b=#{day}&c=#{yr}&d=#{mnth2}&e=#{day2}&f=#{yr2}&g=d&ignore=.csv")
        @raw = resp.body.split(/[,\n]/) #gotta split on comma and newline
      end
    end

    def raw
      @raw
    end

    def by_day
      result = []
      rc = @raw
      rc = rc.drop(7) # removes the headers
      (rc.count/7).times do |i|
        b = i*7
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
