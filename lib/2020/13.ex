import AOC

aoc 2020, 13 do
  def p1 do
    [earliest, busses] = input_string()
    |> String.trim()
    |> String.split("\n")
    earliest = String.to_integer(earliest)
    busses = busses
    |> String.split(",")
    |> Enum.reject(& &1 == "x")
    |> Enum.map(&String.to_integer/1)
    departure = Stream.iterate(earliest, & &1 + 1)
    |> Enum.find(fn t -> Enum.any?(busses, fn b -> Integer.mod(t, b) == 0 end) end)
    bus = Enum.find(busses, fn bus -> Integer.mod(departure, bus) == 0 end)
    bus * (departure - earliest)
  end

  def p2 do
    parse_p2()
    |> IO.inspect()
    |> Enum.reduce(&combine_phases/2)
  end

  def parse_p2 do
    input_string()
    |> String.trim()
    |> String.split("\n")
    |> Enum.at(1)
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.reject(fn {e, _} -> e == "x" end)
    |> Enum.map(fn {e, o} -> {String.to_integer(e), o} end)
  end

  # After bus1 and bus2 sync up, the time to their next sync is (bus1 * bus2). So, we only have to check
  # those times. After bus3 syncs up, the time to the sync up is (bus1 * bus2 * bus3), and so.
  def combine_phases({e1, o1} = left, {e2, o2} = right) do
    IO.inspect(left, label: "left")
    IO.inspect(right, label: "right")
    o2 = if o2 == 0, do: e2, else: o2
    next = Stream.iterate(e2, & &1 + o2)
    |> Enum.find(& Integer.mod(&1 + o1, e1) == 0)
    |> IO.inspect(label: "next")
    IO.inspect(e1 * o2, label: "e1 * o2")
    {next, e1 * o2}
  end
end
