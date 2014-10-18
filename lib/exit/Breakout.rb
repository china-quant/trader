require 'date'
require_relative 'Exit'
module Exit
  class Breakout < Exit
    def initialize(params)
      @start_date = params[:start_date]
      @dayData = params[:data]
      @open = params[:open] ? params[:open] : 21
      @long = params[:long] ? params[:long] : false
    end

    def run
      initial_stop = 0
      stop = 0
      entry = 0
      exit_date = 0
      @dayData.each_index do |i|
        day = @dayData[i]
        if day.date == @start_date
          if @long
            # choose between ideal, and margin-limited possible action
            stop = [x_day_extremes(@open, i)[:low], day.open-(0.01*day.open/2)].min
          else
            stop = [x_day_extremes(@open, i)[:high], day.open+(0.01*day.open/2)].max
          end
          initial_stop = stop
          entry = day.open
        end

        if day.date >= @start_date
          old_stop = stop
          extrs = x_day_extremes(@open, i)
          if @long
            stop = extrs[:low]
            stop = [old_stop, stop].max
            stop = [stop, initial_stop].max
            if day.low < stop 
              exit_date = day.date
              break
            end
          else
            stop = extrs[:high]
            stop = [old_stop, stop].min #always move stop lower, or keep it same
            stop = [stop, initial_stop].min
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

    def x_day_extremes(x, ind)
      lowest = 1000000000
      highest = 0
      x.to_i.times do |i|
        day = @dayData[ind-(i+1)]
        lowest = day.low < lowest ? day.low : lowest
        highest = day.high > highest ? day.high : highest
      end

      return {low: lowest, high: highest}
    end
  end
end
