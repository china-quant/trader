require_relative 'EntrySystem'
require_relative '../Breakout'
require_relative '../SMA'
module Entry
  # this is a simple x-day breakout system, it goes the direction price breaks out
  class Breakouts < EntrySystem
    def initialize(params)
      @data = params[:data]
      @start = params[:start]
      @breaks = Stocks::Breakout.new(@data, [params[:days]])
    end

    # scans the time period, returning days that entries are signaled
    def run
      entries = []
      @data.each do |day|
        ind = @data.find_index(day)
        if day.date > @start && is_good(day)
          if @breaks.value(ind-1).include? "up" #see is_good for why -1
            entries.push({ day: day, long: true })
          else
            entries.push({ day: day, long: false })
          end
        end
      end

      return entries
    end

    def is_good(day)
      ind = @data.find_index(day) -1
      # ind -1, because we will buy/short the open if yesterday was a breakout
      return @breaks.value(ind) != -1
    end
  end
end
