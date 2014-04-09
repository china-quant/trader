module Stocks
  # the end date is always the present
  class DataGetter
    SOURCE = "ichart.yahoo.com"

    def initialize(start_date, ticker)
      @start_date = start_date
      @ticker = ticker
    end

    def get_raw
      day = @start_date.day
      mnth = @start_date.month - 1
      yr = @start_date.year
      day2 = Date.today.day
      mnth2 = Date.today.month - 1
      yr2 = Date.today.year
      Net::HTTP.start(SOURCE) do |http|
        resp = http.get("/table.csv?s=#{company}&a=#{mnth}&b=#{day}&c=#{yr}&d=#{mnth2}&e=#{day2}&f=#{yr2}&g=d&ignore=.csv")
        @raw = resp.body.split(',')
      end
    end
  end
end
