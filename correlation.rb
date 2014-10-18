#!/usr/bin/env ruby
# usage: ./correlation.rb [# stocks to pick] [yyyy-mm-dd]

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


def do_script
  # make the list of stock to check
  sp500list = []
  f = File.open("sp500list.csv", "r")
  f.each_line do |line|
    sp500list = line.split(",")
  end
  f.close
  sp500list = sp500list.reverse.drop(1).reverse

  start_date = Date.parse(ARGV[1])

  puts "Getting Data for SPY..."
  data = Stocks::DataGetter.new(start_date, "spy")
  dayData = data.by_day
  returns = log_returns(dayData)
  expted_val = expt(returns)
  data_prime = array_prime(returns, expted_val)

  # compare spy to component stocks
  cov_arr = []
  sp500list.each do |ticker|
    print "Getting Data for #{ticker}... "
    data1 = Stocks::DataGetter.new(start_date, ticker)
    dayData1 = data1.by_day
    returns1 = log_returns(dayData1)
    expted_val1 = expt(returns1)
    data_prime1 = array_prime(returns1, expted_val1)
    q_p_r_p = multiply_arrays(data_prime, data_prime1)

    covariance = expt(q_p_r_p)
    correlation = covariance/(std_dev(returns) * std_dev(returns1))
    cov_arr.push [correlation.abs, ticker]
    puts  " correlation coefficient = #{correlation}"
  end

  cov_arr.sort! { |x,y| x[0] <=> y[0]} 

  ARGV[0].to_i.times do |i|
    print "#{i}: #{cov_arr[i][1]} @ #{cov_arr[i][0]}\n"
  end
end

# returns the expected value of an array
def expt(arr)
  arr.inject{ |sum, el| sum + el }.to_f / arr.size
end

# returns an array of daily % changes based on closing prices
def log_returns(arr)
  array = []
  arr.each_index do |i|
    array.push ((arr[i].close - arr[0].close)/arr[0].close) unless i == 0
  end
  return array
end

def array_prime(arr, exp)
  array = []
  arr.each do |val|
    array.push val-exp
  end
  return array
end

def multiply_arrays(arr, arr2)
  array = []
  arr.each_index do |i|
    array.push (arr[i]*arr2[i])
  end
  return array
end

def std_dev(arr)
  return Math.sqrt(sample_variance(arr))
end

def sample_variance(arr)
  m = expt(arr)
  sum = arr.inject(0){|accum, i| accum + (i - m) ** 2 }
  return sum / (arr.length - 1).to_f
end

if ARGV.count > 1
  do_script
else
  puts "usage: ./correlation.rb [# stocks to pick] [yyyy-mm-dd]"
end
