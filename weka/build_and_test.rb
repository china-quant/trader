#!/usr/bin/env ruby
# make sure the weka classpath is set up:
# `export CLASSPATH=$CLASSPATH:/Volumes/weka-3-6-12/weka-3-6-12/weka.jar`
# then:
# ./build_and_test.rb [ticker] [start date] [end date] [n days before] [any other options will be passed along straight up]
# the code will automatically split your timespan into two halves. So, to test over the year of 2014, start is 2013-01-01 and end is 2015-01-01.
# example:
#  `./build_and_test.rb spy 2012-01-01 2014-01-01 5 --min-profit 0.66`

require 'open3'
require 'date'

def do_script
  options = parse_options

  # data pull/parsing
  # generate the training data
  cmd = "./uptrend_n_days_before_miner.rb #{options[:ticker]} #{options[:start_date]} #{options[:n_days_before]} -e #{options[:mid_date]}"# > training/spy_2012-2013_5d_hlc_0-2.arff"
  options[:extra].each do |arg|
    cmd += " #{arg}"
  end
  cmd += " > training/train.arff"
  Open3.popen3(cmd) # runs the command, no std out to dick with, files are written.
  # generate the test data (same as above, but with different dates)
  cmd = "./uptrend_n_days_before_miner.rb #{options[:ticker]} #{options[:mid_date]} #{options[:n_days_before]} -e #{options[:end_date]}"
  options[:extra].each do |arg|
    cmd += " #{arg}"
  end
  cmd += " > test_sets/test.arff"
  Open3.popen3(cmd) # runs the command, no std out to dick with, files are written.

  # WEKA stuff
  # clear old model
  Open3.popen3("rm models/j48.model")
  # generate model from training data
  res = ""
  Open3.popen3("java weka.classifiers.trees.J48 -C 0.25 -M 2 -t ./training/train.arff -d ./models/j48.model") do |sin,sout,serr|
    res = sout.read + serr.read
  end
  # generate predictions on test data
  predictions = ""
  Open3.popen3("java weka.classifiers.trees.J48 -l ./models/j48.model -T ./test_sets/test.arff -p 0") do |stdin, stdout, stderr, wait_thr|
    predictions = stdout.read + stderr.read
  end
#  predictions = predictions.gsub(/.*inst#     actual  predicted error prediction/,'')

  # run model_tester.rb on predictions


  puts res
  puts predictions
end

def parse_options
  options = {
    ticker: ARGV[0],
    start_date: ARGV[1],
    end_date: ARGV[2],
    n_days_before: ARGV[3].to_i,
    extra: []
  }
  options[:mid_date] = Date.parse(options[:start_date]) + ((Date.parse(options[:end_date]) - Date.parse(options[:start_date]))/2)
  options[:mid_date] = options[:mid_date].to_s
  ARGV.each_with_index do |arg, index|
    next if index <= 3
    options[:extra] << arg
  end
  return options
end

if ARGV.count >= 4
  do_script
else
  puts "see usage in file"
end
