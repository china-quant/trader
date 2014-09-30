#!/usr/bin/env ruby
# usage: ./exit-test.rb [date of entry] [ticker] -s
# -s makes it calculate for going short @ open of day
# example: ./exit-test.rb 01/02/2013 atvi
#   => exit: $15.51, 04/01/2013
#      entry: $10.85, stop: $9.00

require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'
require_relative 'lib/ATR'
require_relative 'lib/exit/FourHalfR'
require_relative 'lib/exit/ProfitDecayATR'

start_date = Date.parse(ARGV[0])
data_start_date = start_date - 25 # get data for a bit earlier for avgs/atr stuff
data = Stocks::DataGetter.new(data_start_date, ARGV[1])
dayData = data.by_day
atr = Stocks::ATR.new(dayData, [15])
#puts atr.to_s

puts "time decay 4.5 ATR:"
puts "#{((Exit::FourHalfR.new({atr: atr, data: dayData, start_date: start_date, long: true})).run)[:str]}"
puts "\nprofit decay 4.5 ATR:"
puts "#{((Exit::ProfitDecayATR.new({atr: atr, data: dayData, start_date: start_date, long: true})).run)[:str]}"
