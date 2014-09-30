require 'date'
require_relative 'Exit'
module Exit
  class FourHalfR < Exit
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
          num_days = (day.date - @start_date).to_i
          old_stop = stop
          atr_factor = [@open-(num_days*0.1), 0.8].max
          if @long
            stop = [(@dayData[i-1].low - (atr_factor * @atr.value(i))), @dayData[i-1].low].min
            stop = [old_stop, stop].max
            stop = [stop, initial_stop].max
          else
            stop = [(@dayData[i-1].high + (atr_factor * @atr.value(i))), @dayData[i-1].high].max
            stop = [old_stop, stop].min #always move stop lower, or keep it same
            stop = [stop, initial_stop].min
          end
          if day.low < stop && @long
            exit_date = day.date
            break
          end
          if day.high > stop && !@long
            exit_date = day.date
            break
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
