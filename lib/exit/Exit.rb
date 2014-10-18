module Exit
  class Exit

    def long=(date)
      @long = date
    end
    def start_date=(date)
      @start_date = date
    end
    def open=(thing)
      @open = thing
    end

    def run
      
      return {
        str: "exit: #{}, $#{}\nentry: $#{}, stop: $#{}",
        exit_date: nil,
        exit_price: nil,
        entry: nil,
        stop: nil,
        entry_date: @start_date,
        long: @long
      }
    end
    
  end
end

