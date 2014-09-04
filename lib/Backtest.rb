require 'date'

module Stocks
  class Backtest
    def initialize(data, system)
      @data = data
      @system = system  # object that needs to respond to #enter? #entry #exit? #exit
    end

    def system=(sys)
      @system = sys
    end

    def run_test
      entered = false
      entry = {} # entry price
      resR = 0
      res_arr = []
      totalR = 0
      @data.each do |day|
        if !entered && @system.enter?(day, @data)
          entry = @system.entry(day, @data)
          entered = true
        elsif entered && @system.exit?(day, @data)
          resR = @system.exit(day, @data, entry) # #exit returns the R change from the trade
          totalR += resR
          res_arr.push({ entry: entry, day: day, r: resR, tR: totalR})
          entered = false
        end
      end

      res_arr.each do |trade|
        
      end

      return {
              array: res_arr,
              string: "Total Return: #{totalR}R\nExpectancy: #{totalR/((Date.today - @data[0].date).to_i)}",
              tR: totalR
             }
    end
  end
end
