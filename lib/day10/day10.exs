defmodule Memo do
  use Agent

  def start_link() do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn state -> Map.get(state, key) end)
  end

  def update(key, value) do
    Agent.update(__MODULE__, fn state -> Map.put(state, key, value) end)
  end

  def reset do
    Agent.update(__MODULE__, fn _ -> Map.new end)
  end
end

defmodule Day10 do
  def parse_input(input) do
    input = input
    |> String.trim
    |> String.split
    |> Enum.map(&String.to_integer/1)
    max = Enum.max(input) + 3
    Enum.sort([ max | [ 0 | input ]])

  end

  def differences(jolts) do
    jolts
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(& elem(&1, 1) - (elem(&1, 0)))
  end

  def part1(diffs) do
    ones = Enum.count(diffs, & &1 == 1)
    threes = Enum.count(diffs, & &1 == 3)
    ones * threes
  end

  def part2(jolts, start) do
    cache = Memo.get(start)
    if cache do
      cache
    else
      connections = Enum.filter(jolts, & &1 > start and &1 <= start + 3)
      if Enum.empty?(connections) do
        1
      else
        res = connections
        |> Enum.map(fn c -> part2(Enum.drop_while(jolts, & &1 <= c), c) end)
        |> Enum.sum
        Memo.update(start, res)
        res
      end
    end
  end
end

File.read!("input") |> Day10.parse_input() |> Day10.differences() |> Day10.part1() |> IO.inspect()

test_input1 = "16 10 15 5 1 11 7 19 6 12 4"

Memo.start_link()
test_input1 |> Day10.parse_input() |> Day10.part2(0) |> IO.inspect()

test_input2 = "28 33 18 42 31 14 46 20 48 47 24 23 49 45 19 38 39 11 1 32 25 35 8 17 7 9 4 2 34 10 3 "

Memo.reset()
test_input2 |> Day10.parse_input() |> Day10.part2(0) |> IO.inspect()

Memo.reset()
File.read!("input") |> Day10.parse_input() |> Day10.part2(0) |> IO.inspect()
