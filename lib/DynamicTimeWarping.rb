module Stocks
  # useful for measuring the 'distance' between two arrays of numbers that are ordered in time
  class DynamicTimeWarping
    def initialize(arr1, arr2)
      @arr1 = arr1
      @arr2 = arr2
    end

    # used to get the actual distance between the arrays
    def distance
      arr1_max = @arr1.sort[-1]
      arr2_max = @arr2.sort[-1]
      max = arr1_max > arr2_max ? arr1_max : arr2_max

      if arr1_max > arr2_max
        diff = arr1_max - arr2_max
        norm_arr2 = []
        @arr2.each do |e|
          norm_arr2.push(e + diff)
        end

        puts norm_arr2 # this array is now 'lined up' with @arr1
      else
        diff = arr2_max - arr1_max
        norm_arr1 = []
        @arr1.each do |e|
          norm_arr1.push(e + diff)
        end

        puts norm_arr1 # this arr is now 'lined up' w/ @arr2
      end

    end
  end
end
