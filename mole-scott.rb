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
require_relative 'lib/entry/Breakouts'
require_relative 'lib/exit/Breakout'
require_relative 'lib/exit/FourHalfR'

def generic_breakout_test(days, exit_sys, data, start_date, verbose)
  entry_sys = Entry::Breakouts.new({
    data: data,
    start: start_date,
    days: days
  })
  test = Stocks::Backtest2.new(data, entry_sys, exit_sys)
  result = test.run_test

  result[:array].each do |res|
    puts res[:str] + " #{res[:entry_date]}"
  end if verbose == 2
  puts result[:string] if verbose >= 1
  return result
end

def search_breakout_generic(verbose, dayData, start_date, exit_sys)
  bestNetR = 0
  bestOpen = 0
  bestDays = 0 
  puts "netR,daysToBreakout,exitParam"
  50.times do |i|
    p = i +10
    30.times do |j|
      open = j+3
      exit_sys.open = open
      r = generic_breakout_test(p, exit_sys, dayData, start_date, 0)
      if r[:netR] > bestNetR
        bestNetR = r[:netR]
        bestOpen = open
        bestDays = p
      end
      puts "#{r[:netR]},#{p},#{open}" if verbose
    end
  end

  return {
    netR: bestNetR,
    days: bestDays,
    open: bestOpen
  }
end
#verbose - int 0,1,2 where 0 is no prints, and 2 is the most prints
def run_breakout_test(days, open_atr, data, start_date, verbose, atr)
  entry_sys = Entry::Breakouts.new({
    data: data,
    start: start_date,
    days: days
  })
  exit_sys  = Exit::FourHalfR.new({
    atr: atr,
    data: data,
    open: open_atr
  })
  test = Stocks::Backtest2.new(data, entry_sys, exit_sys)
  result = test.run_test

  result[:array].each do |res|
    puts res[:str] + " #{res[:entry_date]}"
  end if verbose == 2
  puts result[:string] if verbose >= 1
  return result
end

def search_breakout_atr_time_decay(verbose, dayData, start_date, atr)
  bestNetR = 0
  bestOpen = 4.5
  bestDays = 0 
  puts "netR,daysToBreakout,initialATRfactor"
  50.times do |i|
    p = i +10
    30.times do |j|
      open = (j+10).to_f/10
      r = run_breakout_test(p, open, dayData, start_date, 0, atr)
      if r[:netR] > bestNetR
        bestNetR = r[:netR]
        bestOpen = open
        bestDays = p
      end
      puts "#{r[:netR]},#{p},#{open}" if verbose
    end
  end

  return {
    netR: bestNetR,
    days: bestDays,
    open: bestOpen
  }
end

def do_script
  start_date = Date.parse(ARGV[1])
  data_start_date = start_date - 65 # get data for a bit earlier for avgs/atr stuff
  puts "Getting Data..."
  if ARGV[0].upcase == "EURUSD"
    data = Stocks::DataGetter2.new(data_start_date, ARGV[0].upcase)
  else
    data = Stocks::DataGetter.new(data_start_date, ARGV[0])
  end
  dayData = data.by_day

  # calc atr(15) array
  atr = Stocks::ATR.new(dayData, [15])

=begin
  # setup and run test
  puts "running initial candle pattern test..."
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
=end
  # New test
# puts "finding optimal breakout day len and atr open..."
# b_atd = search_breakout_atr_time_decay(true, dayData, start_date, atr)
# puts "ideal (days, atr_open) = (#{b_atd[:days]}, #{b_atd[:open]}) with netR of #{b_atd[:netR]}"
  extsys  = Exit::Breakout.new({
    data: dayData,
    open: 28
  })
  resu = generic_breakout_test(55, extsys, dayData, start_date, 0)
  resu[:array].each do |res|
    puts res[:str] + " #{res[:entry_date]}"
  end
  puts resu[:string]
# b_b = search_breakout_generic(true, dayData, start_date, extsys)
# puts "ideal (days, days) = (#{b_b[:days]}, #{b_b[:open]}) with netR of #{b_b[:netR]}"
end

if ARGV.count > 1
  do_script
else
  puts "usage: ./scott-mole.rb [ticker] [yyyy-mm-dd]"
end
