#!/usr/bin/env ruby
# ./model_tester.rb [ticker] [yyyy-mm-dd] [predictions filename] -e [optional end-date yyyy-mm-dd]
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

  puts "Loading Predictions..." if options[:verbose]
  predictions = IO.read(ARGV[2]).split("\n").select{|line| line[4] && line[5] && (line[4]+line[5]).to_i != 0 }.map do |line|
    line[23] == '1'
  end # is now an array of true/false where true => yes => buy

  capital = 10000.0
  stop = 0.0
  initial_stop = 0.0
  entry = 0.0
  shares = 0
  in_trade = false
  r_log, capital_log, shares_log, entry_log, exit_log = [], [], [], [], []
  day_data.each_with_index do |day, index|
    if in_trade
      # see if we were stopped out today
      if day.low < stop
        in_trade = false
        if day.open < stop # gapped
          r_log << ((day.open - entry)/(entry - initial_stop))
          capital = capital + (shares*day.open)
          capital_log << capital
          exit_log << day.open
        else # normal stop out
          r_log << ((stop - entry)/(entry - initial_stop))
          capital = capital + (shares*stop)
          capital_log << capital
          exit_log << stop
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
        if shares*entry > capital*2
          shares = (capital*2 / entry).to_i
          capital -= shares * entry
        else
          capital -= shares * entry
        end
        shares_log << shares
        entry_log << entry
        print "." if options[:verbose]
      end
    end
  end

  puts "This model was run from #{start_date} to #{options[:end_date] || Date.today} on #{ARGV[0]}"
  puts "capital: #{capital}\tavgR: #{r_log.inject{ |sum, el| sum + el }.to_f / r_log.size}\ttotal R: #{r_log.inject{ |sum, el| sum + el }.to_f}"
  puts "total trades: #{r_log.count}\twins: #{r_log.select{|r| r>0}.count}\tlosses: #{r_log.select{|r| r<=0}.count}"
  puts "avg win: #{r_log.select{|r| r>0}.inject{ |sum, el| sum + el }.to_f / r_log.select{|r| r>0}.size}\tavg loss: #{r_log.select{|r| r<=0}.inject{ |sum, el| sum + el }.to_f / r_log.select{|r| r<=0}.size}\t"
  puts "biggest win: #{r_log.inject{|win, el| win < el ? el : win}}\tbiggest loss: #{r_log.inject{|loss, el| loss > el ? el : loss}}"
  puts "R log, capital log, shares log, entry log, exit log:\n"
  r_log.each_with_index do |r, index|
    print "#{r.to_f.round(2)}\t#{capital_log[index].to_f.round(2)}\t#{shares_log[index].to_f.round(2)}\t#{entry_log[index].to_f.round(2)}\t#{exit_log[index].to_f.round(2)}\n"
  end

end

def parse_options
  options = {
    jump_r: 0.4,
    inc_r: 0.09,
    min_profit: 0.2,
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
