#!/usr/bin/env ruby
# usage: ./opensp500.rb [anything]
# this will fetch pngs of either the sp100 charts or sp500 charts (if anything is passed), and save them to the disk in a directory called 'pages'

require 'net/http'
require 'date'


def do_script
  filename = "sp100list.csv"
  if ARGV.count != 0
    filename = "sp500list.csv"
  end
  # make the list of stock to check
  sp500list = []
  f = File.open(filename, "r")
  f.each_line do |line|
    sp500list = line.split(",")
  end
  f.close
  sp500list = sp500list.reverse.drop(1).reverse # cleans off the last garbage result
  sp500list = sp500list + ["iyw","spy","dia","qqq", "bbry"] # add some etfs and a favourite

  start_date = Date.today-10

  list = []
  sp500list.each do |ticker|
    print "Getting Data for #{ticker}... "
    Net::HTTP.start("stockcharts.com") do |http|
      resp = http.get("/c-sc/sc?s=#{ticker}&p=D&b=4&g=0&id=p10348519835")
      File.write("./pages/#{ticker}.png",resp.body)
    end
  end
end

do_script
