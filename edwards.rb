# This program accesses stock market data from the web, and analyzes it with modern data mining techniques.
# Since stock market data is necesarily time-series data, time series algorithms and techinques are used.
# particular focus is given to the tasks of Clustering, Classification (of sub-sets of the larger data), and Prediction.
# hopefully, edwards will help you make some money in the market.

require 'net/http'
require 'date'


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
