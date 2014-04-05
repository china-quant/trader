def to_bool(str)
  str == "true"
end

data = IO.read("dia.csv").split(',')  # reads in the data, minus header line

index = 0
new_data = []
open = 0
data.each do |item|
  case index
  when 1
    open = item.to_f
  when 4
    if item.to_f >= open
      new_data.push(true)
    else
      new_data.push(false)
    end
  else
    #do nothing
  end
  index +=1
  index = 0 if index == 6
end

new_data = new_data.reverse

min_supp = 3

freq = []
occurence_count = []
potential = []
#detect all frequen 5-day patterns
i = 0
while (i+5) < new_data.length
  pattern = [
    new_data[i],
    new_data[i+1],
    new_data[i+2],
    new_data[i+3],
    new_data[i+4]
  ]
  if freq.include? pattern
    j = freq.rindex(pattern)
    occurence_count[j] = occurence_count[j] + 1
  elsif potential.include? pattern
    freq.push pattern
    occurence_count.push 1
  else
    potential.push pattern
  end
  i+=1
end

nf = []
oc = []
occurence_count.each.with_index(1) do |item, ind|
  if item >= min_supp
    nf.push freq[ind]
    oc.push item
  end
end

# show the frequent patterns
puts "Frequent weeks are:"
nf.each do |item|
  puts "#{item[0]},#{item[1]},#{item[2]},#{item[3]},#{item[4]}: #{oc[nf.rindex(item)]}"
end

if ARGV.length > 0
  possible = []
  nf.each do |item|
    matches = true
    ARGV.each do |arg|
      bool = (arg == "true")
      if bool != item[ARGV.rindex(arg)]
        matches = false
      end
    end
    if matches
      possible.push item
    end
  end
  possible.each do |item|
    puts "#{item[0]},#{item[1]},#{item[2]},#{item[3]},#{item[4]}"
  end
end
