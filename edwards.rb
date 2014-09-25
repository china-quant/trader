#!/usr/bin/env ruby
# This program accesses stock market data from the web, and analyzes it with modern data mining techniques.
# Since stock market data is necesarily time-series data, time series algorithms and techinques are used.
# particular focus is given to the tasks of Clustering, Classification (of sub-sets of the larger data), and Prediction.
# hopefully, edwards will help you make some money in the market.

require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'
require_relative 'lib/DataGetter2'
require_relative 'lib/DynamicTimeWarping'
require_relative 'lib/Backtest'
require_relative 'lib/SMASystem'
require_relative 'lib/DailyCloseSystem'
require_relative 'lib/PerfectSystem'
require_relative 'lib/CandleSystem'
require_relative 'lib/ExitOnlySystem'

start_date = Date.parse(ARGV[1])
if ARGV[0].upcase == "EURUSD"
  data = Stocks::DataGetter2.new(start_date, ARGV[0].upcase)
else
  data = Stocks::DataGetter.new(start_date, ARGV[0])
end
dayData = data.by_day
# puts dayData

puts "FINIDING MAXIMUM PROFIT FROM PERFECT FUTURE PREDICTION:"
s = Stocks::PerfectSystem.new
t = Stocks::Backtest.new(dayData, s)
puts "\t#{t.run_test[:string]}"

=begin
puts "\n\nFINDING best SMA:signal-flip parameter:"

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
    puts "\tnew params: #{sys1.params} is better"
  else
    fails+=1
    should_search = false if fails > 50
  end
  new_param = growing ? new_param+1 : new_param-1
end

puts "\t"+last_result[:string]

puts "\n\nFINDING BULL/BEAR via Daily Close:"
bull_result = (Stocks::Backtest.new(dayData, Stocks::DailyCloseSystem.new({bull:true}))).run_test
bear_result = (Stocks::Backtest.new(dayData, Stocks::DailyCloseSystem.new({bull:false}))).run_test

if bull_result[:tR] > bear_result[:tR]
  puts "\tbull\n\t#{bull_result[:string]}"
else
  puts "\tbear\n\t#{bear_result[:string]}"
end

puts "\n\nTESTING CANDLE SYSTEM:"
puts "\t#{(Stocks::Backtest.new(dayData, Stocks::CandleSystem.new())).run_test[:string]}"
=end
puts "\n\nFINDING best ENTER-TRUE:X-AWAY parameter:"

sys = Stocks::ExitOnlySystem.new({stop: 1, up: true})
test = Stocks::Backtest.new(dayData, sys)
start_result = test.run_test
# puts test.run_test[:array]
should_search = true
last_result = start_result
new_param = 2
growing = true
fails = 0

while should_search do
  sys1 = Stocks::ExitOnlySystem.new({up: true, stop: new_param})
  test1 = Stocks::Backtest.new(dayData, sys1)
  new_result = test1.run_test
  if new_result[:tR] >= last_result[:tR]
    last_result = new_result
    puts "\tnew params: #{sys1.params} is better"
  else
    fails+=1
    should_search = false if fails > 50
  end
  new_param = growing ? new_param+1 : new_param-1
end

puts "\t"+last_result[:string]
puts last_result[:array]
