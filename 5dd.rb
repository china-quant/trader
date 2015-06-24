#!/usr/bin/env ruby
# usage: ./5dd.rb [-500]
# => XXX,XXX,XXX (list of symbols in the sp500 that have had 5 down days)

require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'
require_relative 'lib/FiveDD'
require_relative 'lib/FiveUD'

def do_script
  filename = "sp100list.csv"
  use_up = false
  if ARGV.count != 0
    filename = "sp500list.csv"
    if ARGV.count >1 # if there is a second param
      use_up = true
    end
  end
  # make the list of stock to check
  sp500list = []
  f = File.open(filename, "r")
  f.each_line do |line|
    sp500list = line.split(",")
  end
  f.close
  sp500list = sp500list.reverse.drop(1).reverse # cleans off the last garbage result
  sp500list = sp500list + ["iyw","spy","dia","qqq","dog","sco","sh"] # add some etfs

  start_date = Date.today-10

  list = []
  four_list = []
  sp500list.each do |ticker|
    print "#{ticker}\t"
    data = Stocks::DataGetter.new(start_date, ticker)
    dayData = data.by_day
    fivedd = Stocks::FiveDD.new(dayData) unless use_up
    fivedd = Stocks::FiveUD.new(dayData) if use_up
    list.push ticker if fivedd.value(dayData.count-1) == true
    four_list.push ticker if fivedd.value(dayData.count-2) == true
  end
  print "\nFives:\n"

  puts list

  print "\nFours:\n"

  puts four_list

end


#if ARGV.count > 1
  do_script
#else
#  puts "usage: ./5dd.rb"
#end
