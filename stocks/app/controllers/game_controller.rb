require 'net/http'
class DayData
  def initialize(close=0)
    @close = close
  end

  def close
    @close
  end

  def close=(val)
    @close = val
  end
end

def get_year_arr_from( date, company = "GOOG" )
  arr = []
  day = date.day
  mnth = date.month - 1
  yr = date.year
  Net::HTTP.start('ichart.yahoo.com') do |http|
    resp = http.get("/table.csv?s=#{company}&a=#{mnth}&b=#{day}&c=#{yr}&d=#{mnth}&e=#{day}&f=#{yr+1}&g=d&ignore=.csv")
    arr = resp.body.split(',')
  end

  arr.reverse.pop(7)

  f_arr = []
  arr.each_index do |i|
    if ((i % 7) == 1)
      day = DayData.new
      day.close = arr[i]
      f_arr.push( day )
    end
  end

  return f_arr
end

class GameController < ApplicationController
  def new
    @stock = "GOOG"
    @history = get_year_arr_from( Date.today - 400)
  end

  def next
  end
end
