#!/usr/bin/env ruby
# puts results in a directory

require 'open3'

def do_script
  options = parse_options

  tickers = %w(spy dia gld nnn qqq k uso)
  starts  = %w(2010-01-01 2011-01-01 2012-01-01 2013-01-01 2010-01-01 2011-01-01 2012-01-01 2010-01-01 2011-01-01 2010-01-01)
  ends    = %w(2012-01-01 2013-01-01 2014-01-01 2015-01-01 2013-01-01 2014-01-01 2015-01-01 2014-01-01 2015-01-01 2015-01-01)
#  out, err, status = Open3.capture3("export CLASSPATH=$CLASSPATH:/Volumes/weka-3-6-12/weka-3-6-12/weka.jar")
  tickers.each do |tick|
    starts.each_with_index do |start, ind|
      best, days, minp = test(tick, start, ends[ind])
      puts "best of #{tick} (#{start} to #{ends[ind]}) is #{best} R per day, with #{days}d, hlc, and #{minp}"
    end
  end
end

def test(ticker, start, endd)
  best = 0
  days = 0
  prof = 0
  (2..10).each do |n|
    (20..90).each do |minp|
      out, err, status = Open3.capture3("./build_and_test.rb #{ticker} #{start} #{endd} #{n} --min-profit 0.#{minp}")
      File.write("results/#{ticker}_#{start}_to_#{endd}_#{n}d_hlc_0dot#{minp}_j48.txt", out)
      if out.split("\n")[1].split(",")[2].to_f > best
        best = out.split("\n")[1].split(",")[2].to_f
        days = n
        prof = minp
      end
    end
  end
  [best, days, prof]
end

def parse_options
  {}
end

do_script
