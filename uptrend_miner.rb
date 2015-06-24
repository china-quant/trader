#!/usr/bin/env ruby
# simple script to find all the days on which a profitable uptrend was possible under the following trading rules:
#  - an 'uptrend' starts on a day which a buy at open, with an initial stop of (low - (high-low)) from the day before, and traded following the rules results in a profit of > 0.2R
# rules:
#   - at the close of each day, move the stop up 0.09R, unless any other rule applies
#   - if the low of the day is > 0.4R, move the stop up to the low minus $0.02.
#   - if the stop would advance beyond the day's low, merely advance it to the low minus $0.02
# the "magic_numbers" are midifiable by extending the parse_options method
#
# the script will spit out the comma-separated list of dates only when run without the -v flag
require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'

def do_script
  options = parse_options

  puts "Getting Data..." if options[:verbose]
  start_date = Date.parse(ARGV[1])
  raw_data = Stocks::DataGetter.new(start_date, ARGV[0])
  day_data = raw_data.by_day

  puts "searching for uptrends" if options[:verbose]
  uptrends = []
  profits = []
  day_data.each_with_index do |day, index|
    next if index == 0
    previous_day = day_data[index-1]
    initial_stop = (previous_day.low - (previous_day.high - previous_day.low))
    entry = day.open
    # some edge cases
    next if entry < initial_stop # we would not enter on a day that gapped low like this
    next if day.low < initial_stop # we were stopped out on the first day

    # main iteration to find R
    open = true
    r = -1.0
    increment = options[:inc_r] * (entry - initial_stop)
    stop = initial_stop
    while open do
      index += 1
      new_day = day_data[index]
      if new_day.nil?
        open = false
        next
      end
      # we were stopped out today
      if stop > new_day.low
        if stop < new_day.open # not gapped
          r = (stop - entry) / (entry - initial_stop)
        else # gapped at open
          r = (new_day.open - entry) / (entry - initial_stop)
        end
        open = false # ends this loop (basically)
      end
      # in-profit stop movement
      if (new_day.low - entry) / (entry - initial_stop) > options[:jump_r] #if we're above the 0.4R mark
        # move the stop to 0.02 below the low
        stop = new_day.low - 0.02
      else # normal stop movement
        if stop + increment > day.low # bounded by price 'cushion'
          stop = new_day.low - 0.02
        else
          stop = stop + increment # actual incrementation
        end
      end
    end
    # we have R, so see if it qualified as an uptrend
    if r > options[:min_profit]
      puts day.date if options[:verbose]
      uptrends << day.date
      profits << r
    end
  end

  # `uptrends` now contains all the dates that a profitable uptrend started
  puts uptrends.join(',')
  if options[:verbose]
    puts "average profit:\t#{profits.inject{ |sum, el| sum + el }.to_f / profits.size}"
    puts "maximum profit:\t#{profits.max}"
    puts "minimum profit:\t#{profits.min}"
    puts "total   profit:\t#{profits.inject{|sum, el| sum + el}}"
  end
end

def parse_options
  options = {jump_r: 0.4, inc_r: 0.09, min_profit: 0.2}
  ARGV.each_with_index do |arg, index|
    options[:verbose] = true if arg == '-v'
    options[:min_profit] = ARGV[index+1].to_f if arg == '--min-profit'
  end
  options
end

if ARGV.count >= 2
  do_script
else
  puts 'usage: ./uptrend_miner.rb [ticker] [yyy-mm-dd] [options (optional) [-v] [--min-profit 0.4]]'
end
