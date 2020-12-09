defmodule Day09 do
  def parse_input do
    {:ok, input} = File.read("input")
    input
    |> String.trim
    |> String.split
    |> Enum.map(&String.to_integer/1)
  end

  def find_first_invalid(numbers) do
    invalid_helper(numbers, 0, 25)
  end

  def invalid_helper(numbers, start, window) do
    addends = Enum.slice(numbers, start, window)
    target = Enum.at(numbers, start + window)
    valid? = for x <- addends,
        y <- addends do
      x + y
    end
    |> Enum.any?(& &1 == target)

    if valid? do
      invalid_helper(numbers, start + 1, window)
    else
      target
    end
  end

  def find_contiguous(numbers, target) do
    contiguous_helper(numbers, target, 0)
  end

  def contiguous_helper(numbers, target, start) do
    addends = Enum.slice(numbers, start..-1)
    reducer = fn(n, set) ->
      set = MapSet.put(set, n)
      sum = Enum.sum(set)
      cond do
        sum < target -> {:cont, set}
        sum == target -> {:halt, set}
        sum > target -> {:halt, false}
      end
    end
    res = Enum.reduce_while(addends, MapSet.new, reducer)
    if res do
      min = Enum.min(res) |> IO.inspect(label: "min: ")
      max = Enum.max(res) |> IO.inspect(label: "max: ")
      min + max |> IO.inspect(label: "total: ")
    else
      # This does not give the correct answer. I misunderstood smallest/largest for first/last.
      contiguous_helper(numbers, target, start + 1)
    end
  end

end

numbers = Day09.parse_input
target = Day09.find_first_invalid(numbers) |> IO.inspect(label: "target: ")
Day09.find_contiguous(numbers, target) |> IO.inspect
