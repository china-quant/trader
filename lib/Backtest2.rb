require 'date'

module Stocks
  # This method of backtesting utilizes separated entry and exit
    # protocols, making it less efficient, but more accurate/applicable
  class Backtest2
    def initialize(data, entry_sys, exit_sys)
      @data = data
      @entry_sys = entry_sys
      @exit_sys = exit_sys
    end

    def entry=(sys)
      @entry_sys = sys
    end

    def exit=(sys)
      @exit_sys = sys
    end

    def run_test
      # first, create an array of entry days on the symbol
      entries = @entry_sys.run
        # each entry is a DataDay object
      # then, run the exit_sys on each entry day, tabulating the results
      exits = []
      entries.each do |hash|
        @exit_sys.start_date = hash[:day].date
        @exit_sys.long = hash[:long]
        exits.push @exit_sys.run
      end
      # clean out the overlapping entries
      exits.delete_if do |trade|
        ind = exits.find_index(trade)
        if ind == 0
          false
        else
          trade[:entry_date] <= exits[ind-1][:exit_date]
        end
      end

      # calculate stats on system
      netR = 0
      totDur = 0
      winCount = 0
      exits.each do |trade|
        if trade[:long]
          rDelta = (trade[:exit_price] - trade[:entry]) / (trade[:entry] - trade[:stop])
        else
          rDelta = (trade[:entry] - trade[:exit_price]) / (trade[:stop] - trade[:entry])
        end
#       duration = (trade[:exit_date] - trade[:entry_date]).to_i
#       totDur += duration
        netR += rDelta
        winCount += 1 if rDelta > 0
      end
      if exits.count > 0
        expectancy = netR / exits.count
        avgDuration = totDur / exits.count
        winRate = winCount / exits.count
      end

      return {
              array: exits,
              string: "Total Return:\n\t\t#{netR} R\n\tExpectancy:\n\t\t#{expectancy} R\n\tTotal Trades:\n\t\t#{exits.count}\n\t",
              netR: netR,
              expectancy: expectancy,
              avgDuration: avgDuration,
              winRate: winRate,
              entries: entries
             }
    end
  end
end
