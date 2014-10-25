#!/usr/bin/env ruby

require 'net/http'

samples = 2000

def getTICK
  Net::HTTP.start('www.barchart.com') do |http|
    resp = http.post("/data/json-quotes.phpx", 
    "keys=%24TICK&extrafields=last_t", {
      "Content-Type" => "application/x-www-form-urlencoded",
      "Referer" => "http://www.barchart.com/quotes/stocks/$TICK"
    })
    if resp.body && resp.body.slice(12,9).gsub(",","") && resp.body.slice(12,9).gsub(",","").to_i
      return resp.body.slice(12,9).gsub(",","").to_i 
    else
      return 10000
    end
  end
end

ticks = []

samples.times do |i|
  sleep 1
  ticks.push getTICK
end

pos = 0
neg = 0
ticks.each do |tick|
 pos += 1 if tick > 10000
 neg += 1 if tick < 10000
end

puts ticks

if pos/samples > 0.9
  puts "HIGH probability of UP-trend day"
elsif pos/samples > 0.8
  puts "MODERATE probability of UP-trend day"
else
  puts "probably not trending up"
end
if neg/samples > 0.9
  puts "HIGH probability of DOWN-trend day"
elsif neg/samples > 0.8
  puts "MODERATE probability of DOWN-trend day"
else
  puts "probably not trending down"
end

