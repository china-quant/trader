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
require_relative '../lib/DayData'
require_relative '../lib/DataGetter'

def do_script
  options = parse_options

  puts "Getting Data..." if options[:verbose]
  start_date = Date.parse(ARGV[1])
  raw_data = Stocks::DataGetter.new(start_date, ARGV[0], options[:end_date])
  day_data = raw_data.by_day

  puts "searching for uptrends" if options[:verbose]
  uptrends = []  # list of dates on which an uptrend starts
  full_days = [] # list of full data from uptrend-starting days
  indexes = []   # list of day_data indexes on which an uptrend starts
  profits = []   # list of profits (in r) from each uptrend
  day_data.each_with_index do |day, index|
    next if index == 0
    init_index = index
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
      full_days << day
      indexes << init_index
      profits << r
    end
  end

  # `uptrends` now contains all the dates that a profitable uptrend started
  if options[:just_days]
    puts uptrends.join(',')
    if options[:verbose]
      puts "average profit:\t#{profits.inject{ |sum, el| sum + el }.to_f / profits.size}"
      puts "maximum profit:\t#{profits.max}"
      puts "minimum profit:\t#{profits.min}"
      puts "total   profit:\t#{profits.inject{|sum, el| sum + el}}"
    end
  else # full ARFF file with n_days
    vectors = []
    if options[:just_uptrends]
      indexes.each do |index|
        next if index - options[:n_days] < 0 # can't look back past the beginning
        day = day_data[index]
        spread = day.high - day.low
        vector = []
        vector << 1.0 if options[:use_high]
        vector << 0.0 if options[:use_low]
        vector << ((day.close - day.low) / spread) if options[:use_close]
        options[:n_days].times do |iteration|
          prev_day = day_data[index - 1 - iteration]
          vector << ((prev_day.high - day.low) / spread) if options[:use_high]
          vector << ((prev_day.low - day.low) / spread) if options[:use_low]
          vector << ((prev_day.close - day.low) / spread) if options[:use_close]
        end
        vector << 'yes'
        vectors << vector
      end
    else # put out a vecotr for every possible day
      day_data.each_with_index do |day, index|
        next if index - options[:n_days] < 0 # can't look back past the beginning
        spread = day.high - day.low
        vector = []
        vector << 1.0 if options[:use_high]
        vector << 0.0 if options[:use_low]
        vector << ((day.close - day.low) / spread) if options[:use_close]
        options[:n_days].times do |iteration|
          prev_day = day_data[index - 1 - iteration]
          vector << ((prev_day.high - day.low) / spread) if options[:use_high]
          vector << ((prev_day.low - day.low) / spread) if options[:use_low]
          vector << ((prev_day.close - day.low) / spread) if options[:use_close]
        end
        vector << (indexes.include?(index) ? 'yes' : 'no')
        vectors << vector
      end
    end

    # puts out the file in correct ARFF format
    print "@RELATION #{options[:n_days]}_days_#{options[:use_high] ? 'h' : ''}#{options[:use_low] ? 'l' : ''}#{options[:use_close] ? 'c' : ''}"
    print "\n\n"
    vectors.first.count.times do |iteration|
      puts "@ATTRIBUTE a#{iteration} NUMERIC" if vectors.first[iteration].is_a? Numeric
      puts "@ATTRIBUTE uptrend {yes,no}" if vectors.first[iteration].is_a? String
    end
    puts "@DATA"
    vectors.each do |vec|
      puts vec.join(',')
    end
  end
end

def parse_options
  options = {
    jump_r: 0.4,
    inc_r: 0.09,
    min_profit: 0.2,
    n_days: ARGV[2].to_i,
    use_close: true,
    use_high: true,
    use_low: true,
    just_uptrends: false,
  }
  ARGV.each_with_index do |arg, index|
    options[:verbose] = true if arg == '-v'
    options[:min_profit] = ARGV[index+1].to_f if arg == '--min-profit'
    options[:just_days] = true if arg == '--just-days'
    options[:use_close] = false if arg == '--no-close'
    options[:use_high] = false if arg == '--no-high'
    options[:use_low] = false if arg == '--no-low'
    options[:just_uptrends] = true if arg == '--just-uptrends'
    options[:end_date] = Date.parse(ARGV[index+1]) if arg == '-e'
  end
  options
end

if ARGV.count >= 3
  do_script
else
  puts "usage: ./uptrend_n_days_before_miner.rb [ticker] [yyy-mm-dd] [n days before] [options (optional) ...]
options:
\t-v\t\t(verbose)
\t--min-profit 0.4
\t--just-days
\t--no-close
\t--no-high
\t--no-low
\t-e yyyy-mm-dd\t\tend date (defaults to today)
\t--just-uptrends\t\tmakes the output only show the found uptrends instead of vectors for every single day"
end
