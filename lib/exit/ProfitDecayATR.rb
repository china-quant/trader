require 'date'
require_relative 'Exit'
module Exit
  class ProfitDecayATR < Exit
    def initialize(params)
      @atr = params[:atr]
      @start_date = params[:start_date]
      @dayData = params[:data]
      @open = params[:open] ? params[:open] : 4.5
      @long = params[:long] ? params[:long] : false
    end

    def run
      stop = 0
      initial_stop = 0
      entry = 0
      exit_date = 0
      largest_profit = 0
      @dayData.each_index do |i|
        day = @dayData[i]
      # print "#{day.date}: #{i}"
        if day.date == @start_date
      #   print " entry! "
          stop = day.high + (@open * @atr.value(i)) unless @long
          stop = day.low - (@open * @atr.value(i)) if @long
          initial_stop = stop
          entry = day.open
        end

        if day.date >= @start_date
          profit = (day.close - entry)/(entry-initial_stop) if @long
          profit = (entry - day.close)/(initial_stop - entry) if !@long
          largest_profit = profit if profit > largest_profit
          atr_factor = [@open - largest_profit, 0.8].max
          old_stop = stop
          if @long
            stop = [(@dayData[i-1].low - (atr_factor * @atr.value(i))), @dayData[i-1].low].min
            stop = [old_stop, stop].max     # never let the stop drop
            stop = [stop, initial_stop].max # never let the stop drop
            if day.low < stop
              exit_date = day.date
              break
            end
          else
            stop = [(@dayData[i-1].high + (atr_factor * @atr.value(i))), @dayData[i-1].high].max #widest of the two
            stop = [old_stop, stop].min     # never let the stop go up
            stop = [stop, initial_stop].min # never let the stop go up
            if day.high > stop
              exit_date = day.date
              break
            end
          end
      #   print "new stop: #{stop}\n"
        end
      #  print "new stop: #{stop}\n" unless stop == 0
      end

      return {
        str: "exit: #{exit_date}, $#{stop.round(2)}\nentry: $#{entry}, stop: $#{initial_stop.round(2)}",
        exit_date: exit_date,
        exit_price: stop,
        entry: entry,
        stop: initial_stop,
        entry_date: @start_date,
        long: @long
      }
    end
  end
end
