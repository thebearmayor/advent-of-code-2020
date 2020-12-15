import AOC

aoc 2020, 15 do
  def p1 do
    numbers = input_string()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    last_number = List.last(numbers)

    start = numbers
    |> Enum.with_index(1)
    |> Enum.map(fn {n, i} -> {n, [i]} end)
    |> Enum.into(%{})

    Stream.iterate({start, last_number, map_size(start) + 1}, &do_round/1)
    |> Enum.find(& elem(&1, 2) == 2021)
    |> elem(1)
  end

  def do_round({numbers, last_number, turn}) do
    prev = Map.get(numbers, last_number, [0])
    say = case prev do
      [_] -> 0
      [m | n] -> m - hd(n)
    end
    {Map.update(numbers, say, [turn], & [turn | [List.first(&1)]]), say, turn + 1}
  end

   def p2 do
    numbers = input_string()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    last_number = List.last(numbers)

    start = numbers
    |> Enum.with_index(1)
    |> Enum.map(fn {n, i} -> {n, [i]} end)
    |> Enum.into(%{})

    Stream.iterate({start, last_number, map_size(start) + 1}, &do_round/1)
    |> Enum.find(& elem(&1, 2) == 30000001)
    |> elem(1)
  end
end
