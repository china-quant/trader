require_relative 'EntrySystem'
module Entry
  # this is a stupid system, it always goes long.
  class Always < EntrySystem
    def initialize(params)
      @data = params[:data]
      @start = params[:start]
    end

    # scans the time period, returning days that entries are signaled
    def run
      entries = []
      @data.each do |day|
        entries.push({ day: day, long: true }) if day.date > @start
      end

      return entries
    end
  end
end
