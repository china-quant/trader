require_relative 'System'
module Stocks
  # this class defines a system that only makes profit through it's exit system.
  # the system always decides to enter, if given the choice, and will alternate it's direction based on the previous result.
    # a loss changes direction, a gain makes direction the same.
  class ExitOnlySystem < System
    def initialize(params = {})
      @params = params
      # :up => true/false
      # :stop => Integer
    end

    def enter?(day, fullData)
      ind = fullData.find_index(day)
      if ind - @params[:stop] > 0
        @params[:up] = @params[:up] ? false : true
        return true
      else
        return false 
      end
    end
    
    def entry(day, fullData)
      ind = fullData.find_index(day)
      stop_day = fullData[ind - @params[:stop]] # set the stop X days away

      if params[:up] == true
        return {price: day.close, stop: [stop_day.low, day.low].min}
      else
        return {price: day.close, stop: [stop_day.high, day.high].max}
      end
    end
    
    def exit?(day, fullData, entry)
      ind = fullData.find_index(day)
      stop_day = fullData[ind - @params[:stop]] # set the stop X days away
      should_exit = false

      if entry[:price] > entry[:stop]  #was a buy trade
        should_exit = true if day.low < entry[:stop]
        should_exit = true if day.low < stop_day.low
      else  # was a short sale trade
        should_exit = true if day.high > entry[:stop]
        should_exit = true if day.high > stop_day.high
      end

      return should_exit
    end

  end
end
