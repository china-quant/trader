require 'date'
module Exit
  class FourHalfR
    def initialize(params)
      @atr = params[:atr]
      @dayData = params[:data]
      @open = params[:open] ? params[:open] : 4.5
    end

    def run
      stop = 0
      initial_stop = 0
      entry = 0
      exit_date = 0
      @dayData.each_index do |i|
        day = @dayData[i]
      # print "#{day.date}: #{i}"
        if day.date == start_date
      #   print " entry! "
          stop = day.low - (@open * @atr.value(i))
          initial_stop = stop
          entry = day.open
        end

        if day.date >= start_date
          num_days = (day.date - start_date).to_i
          old_stop = stop
          atr_factor = [@open-(num_days*0.1), 0.8].max
          stop = [(@dayData[i-1].low - (atr_factor * @atr.value(i))), @dayData[i-1].low].min
          stop = [old_stop, stop].max
          stop = [stop, initial_stop].max
          if day.low < stop
            exit_date = day.date
            break
          end
      #   print "new stop: #{stop}\n"
        end
      #  print "new stop: #{stop}\n" unless stop == 0
      end

      return "exit: $#{stop}, #{exit_date}\nentry: $#{entry}, stop: $#{initial_stop}"
    end
  end
end
