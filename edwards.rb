#!/usr/bin/env ruby
# This program accesses stock market data from the web, and analyzes it with modern data mining techniques.
# Since stock market data is necesarily time-series data, time series algorithms and techinques are used.
# particular focus is given to the tasks of Clustering, Classification (of sub-sets of the larger data), and Prediction.
# hopefully, edwards will help you make some money in the market.

require 'net/http'
require 'date'
require_relative 'lib/DayData'
require_relative 'lib/DataGetter'

data = Stocks::DataGetter.new(ARGV[1], ARGV[0])
