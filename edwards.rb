#!/usr/bin/env ruby
# This program accesses stock market data from the web, and analyzes it with modern data mining techniques.
# Since stock market data is necesarily time-series data, time series algorithms and techinques are used.
# particular focus is given to the tasks of Clustering, Classification (of sub-sets of the larger data), and Prediction.
# hopefully, edwards will help you make some money in the market.

require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'
require_relative 'lib/DynamicTimeWarping'
require_relative 'lib/Backtest'
require_relative 'lib/SMASystem'

start_date = Date.parse(ARGV[1])
data = Stocks::DataGetter.new(start_date, ARGV[0])
dayData = data.by_day
# puts dayData

sys = Stocks::SMASystem.new({num_avgs: 1, first_sma: 2})
test = Stocks::Backtest.new(dayData, sys)
start_result = test.run_test
# puts test.run_test[:array]
should_search = true
last_result = start_result
new_param = 3
growing = true
fails = 0

while should_search do
  sys1 = Stocks::SMASystem.new({num_avgs: 1, first_sma: new_param})
  test1 = Stocks::Backtest.new(dayData, sys1)
  new_result = test1.run_test
#  puts "new_param: #{new_param}, result: #{new_result[:tR]}"
  if new_result[:tR] >= last_result[:tR]
    last_result = new_result
    puts "new params: #{sys1.params} is better"
  else
    fails+=1
    should_search = false if fails > 50
  end
  new_param = growing ? new_param+1 : new_param-1
end

puts last_result[:array]
