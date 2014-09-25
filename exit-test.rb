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
require_relaitve 'lib/exit/FourHalfR'

start_date = Date.parse(ARGV[0])
data_start_date = start_date - 25 # get data for a bit earlier for avgs/atr stuff
data = Stocks::DataGetter.new(data_start_date, ARGV[1])
dayData = data.by_day
atr = Stocks::ATR.new(dayData, [15])
#puts atr.to_s

stop = 0
initial_stop = 0
entry = 0
exit_date = 0
dayData.each_index do |i|
  day = dayData[i]
# print "#{day.date}: #{i}"
  if day.date == start_date
#   print " entry! "
    stop = day.low - (4.5 * atr.value(i))
    initial_stop = stop
    entry = day.open
  end

  if day.date >= start_date
    num_days = (day.date - start_date).to_i
    old_stop = stop
    atr_factor = [4.5-(num_days*0.1), 0.8].max
    stop = [(dayData[i-1].low - (atr_factor * atr.value(i))), dayData[i-1].low].min
    stop = [old_stop, stop].max
    stop = [stop, initial_stop].max
    if day.low < stop
      exit_date = day.date
      break
    end
#   print "new stop: #{stop}\n"
  end
#  print "new stop: #{stop}\n" unless stop == 0
end

puts "exit: $#{stop}, #{exit_date}\nentry: $#{entry}, stop: $#{initial_stop}"
