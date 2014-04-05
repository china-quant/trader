require 'net/http'
require 'date'

def to_bool(str)
  str == "true"
end

class DayData
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
  puts f_arr
  arr.each_index do |i|
    if ((i % 7) == 1)
      f_arr.push(arr[i]) 
    else
      puts "#{i}: i%7 = #{i%7} == 1? => #{i%7 == 1}"
    end
  end

  return f_arr
end

#puts get_year_arr_from Date.today-365
