#!/usr/bin/env ruby
# ./model_tester.rb [ticker] [yyyy-mm-dd] [last n] [predictions filename]
require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'

def do_script
  options = parse_options

  puts "Getting Data..." if options[:verbose]
  start_date = Date.parse(ARGV[1])
  raw_data = Stocks::DataGetter.new(start_date, ARGV[0])
  day_data = raw_data.by_day[(ARGV[2].to_i)..-1]

  puts "Loading Predictions..." if options[:verbose]
  predictions = IO.read(ARGV[3]).split("\n").map do |line|
    line[23] == '1'
  end # is now an array of true/false where true => yes => buy

  capital = 10000.0
  stop = 0.0
  initial_stop = 0.0
  entry = 0.0
  shares = 0
  in_trade = false
  day_data.each_with_index do |day, index|
    if in_trade
      # see if we were stopped out today
      if day.low < stop
        in_trade = false
        if day.open < stop # gapped
          capital = capital + (shares*day.open)
        else # normal stop out
          capital = capital + (shares*stop)
        end
      else # move stop according to rules
        current_r = (day.low - entry) / (entry - initial_stop)
        normal_bump = (entry - initial_stop) * options[:inc_r]
        if current_r > options[:jump_r]
          stop = day.low - 0.02
        elsif stop + normal_bump > day.low
          stop = day.low - 0.02
        else
          stop += normal_bump
        end
      end
    else
      # buy at open next day, unless the open is lower than where we would put the stop
      if predictions[index] && day_data[index+1].open > (day.low - (day.high-day.low))
        in_trade = true
        entry = day_data[index+1].open
        stop = (day.low - (day.high-day.low))
        initial_stop = stop
        shares = ((capital*0.01) / (entry-stop)).to_i
        if shares*entry > capital
          shares = (capital / entry).to_i
          capital -= shares * entry
        else
          capital -= shares * entry
        end
        print "." if options[:verbose]
      end
    end
  end

  puts "capital: #{capital}\t"

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
\t--just-uptrends\t\tmakes the output only show the found uptrends instead of vectors for every single day"
end
