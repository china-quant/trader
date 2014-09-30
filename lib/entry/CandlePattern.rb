require_relative 'EntrySystem'
require_relative '../Candle'
require_relative '../SMA'
module Entry
  # this is a stupid system, it always goes long.
  class CandlePattern < EntrySystem
    def initialize(params)
      @data = params[:data]
      @start = params[:start]
      @candles = Stocks::Candle.new(@data)
      @sma8 = Stocks::SimpleMovingAverage.new(@data, [4])
      @sma21 = Stocks::SimpleMovingAverage.new(@data, [8])
    end

    # scans the time period, returning days that entries are signaled
    def run
      entries = []
      @data.each do |day|
        ind = @data.find_index(day)
        if day.date > @start && is_good(day)
          if @sma8.value(ind) < @sma21.value(ind)
            entries.push({ day: day, long: true })
          else
            entries.push({ day: day, long: false })
          end
        end
      end

      return entries
    end

    def is_good(day)
      ind = @data.find_index(day)
      candles = []
      4.times do |i|
        j = ind - i
        candles.push(@candles.value(j))
      end
      rising_count = 0
      falling_count = 0
      maru_count = 0
      hammer_count = 0
      top_count = 0
      candles.each do |candle|
        rising_count += 1 if candle.include? "rising"
        falling_count += 1 if candle.include? "falling"
        maru_count += 1 if candle.include? "marubozu"
        hammer_count += 1 if candle.include? "hammer"
        top_count += 1 if candle.include? "top"
      end

      two_rising = rising_count == 2 
      two_falling = falling_count == 2 
      two_maru = maru_count == 2
      two_hammer = hammer_count == 2
      no_top = top_count == 0
      both_not_adj = ( candles[0].include?("rising") &&
                     candles[1].include?("falling") ) || 
                     ( candles[0].include?("falling") &&
                     candles[1].include?("rising") )
     return (two_rising && two_falling && both_not_adj) && no_top && (two_hammer || two_maru)
    end
  end
end
