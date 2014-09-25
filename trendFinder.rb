#!/usr/bin/env ruby

require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'

def find_trends(data)
  data.each do |day|
    #do something to figure out if this is a trend 
  end
end

start_date = Date.parse(ARGV[0])
f = File.open("sp500list.csv", "r")
f.each_line do |line|
  stocks = line.split(",")
  stocks.each do |ticker|
    data = Stocks::DataGetter.new(start_date, ticker)
    dayData = data.by_day
    trends = find_trends(dayData)
    puts trends
  end
end
