#!/usr/bin/env ruby
# hopefully, this will help you make some money in the market.
# usage: ./scott-mole.rb [ticker] [yyyy-mm-dd]

require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'
require_relative 'lib/DataGetter2'
require_relative 'lib/Backtest2'
require_relative 'lib/ATR'
require_relative 'lib/entry/Always'
require_relative 'lib/entry/CandlePattern'
require_relative 'lib/exit/FourHalfR'

if ARGV.count > 1
  start_date = Date.parse(ARGV[1])
  data_start_date = start_date - 25 # get data for a bit earlier for avgs/atr stuff
  puts "Getting Data..."
  if ARGV[0].upcase == "EURUSD"
    data = Stocks::DataGetter2.new(data_start_date, ARGV[0].upcase)
  else
    data = Stocks::DataGetter.new(data_start_date, ARGV[0])
  end
  dayData = data.by_day

  # calc atr(15) array
  atr = Stocks::ATR.new(dayData, [15])

  # setup and run test
  puts "running initial test"
  entry_sys = Entry::CandlePattern.new({data: dayData, start: start_date})
  exit_sys  = Exit::FourHalfR.new({
    atr: atr,
    data: dayData,
    open: 1.7
  })
  test = Stocks::Backtest2.new(dayData, entry_sys, exit_sys)
  result = test.run_test

  result[:array].each do |res|
    puts res[:str] + " #{res[:entry_date]}"
  end
  puts result[:string]

  # search for ideal open param
  puts "searching for ideal open atr distance..."
  bestNetR = 0
  bestParam = 4.5
  40.times do |i|
    e = Exit::FourHalfR.new({
      atr: atr,
      data: dayData,
      open: (i+5).to_f/10
    })
    t = Stocks::Backtest2.new(dayData, entry_sys, e)
    r = t.run_test
    if r[:netR] > bestNetR
      bestNetR = r[:netR]
      bestParam = (i+5).to_f/10
    end
  end
  puts "ideal atr distance = #{bestParam} with netR of #{bestNetR}"
else
  puts "usage: ./scott-mole.rb [ticker] [yyyy-mm-dd]"
end
