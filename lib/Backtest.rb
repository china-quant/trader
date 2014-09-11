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
        if entered && @system.exit?(day, @data, entry)
          resR = @system.exit(day, @data, entry) # #exit returns the R change from the trade
          totalR += resR[:r]
          res_arr.push({ entry: entry, day: day, r: resR[:r], percent: resR[:percent]})
          entered = false
        end
        if !entered && @system.enter?(day, @data)
          entry = @system.entry(day, @data)
          entered = true
        end
      end

      tpr = 1
      res_arr.each do |trade|
        tpr = tpr * (1+trade[:percent])
#       print "(#{tpr},#{trade[:percent]})"
      end
      g_mean = tpr**(1.0/res_arr.count)

      return {
              array: res_arr,
              string: "Total Return:\n\t\t#{totalR} R\n\tExpectancy:\n\t\t#{totalR/((Date.today - @data[0].date).to_i)} R\n\tGeometric Mean(per trade):\n\t\t#{g_mean}\n\tTotal Trades:\n\t\t#{res_arr.count}\n\tTotal Percent Return (all $ in each trade):\n\t\t#{tpr*100}",
              tR: totalR
             }
    end
  end
end
