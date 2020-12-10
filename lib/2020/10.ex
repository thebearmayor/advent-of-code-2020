import AOC

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

aoc 2020, 10 do
  def p1 do
    %{1 => f1, 3 => f3} = differences() |> Enum.frequencies()
    f1 * f3
  end

  def p2 do
    Memo.start_link()
    p2_helper(jolts(), 0)
  end

  def jolts do
    jolts = input_stream() |> Enum.map(&String.to_integer/1)
    max = Enum.max(jolts) + 3
    [0 | [ max | jolts]] |> Enum.sort
  end

  def differences do
    jolts()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(& elem(&1, 1) - (elem(&1, 0)))
  end

  def p2_helper(jolts, start) do
    cache = Memo.get(start)
    if cache do
      cache
    else
      connections = Enum.filter(jolts, & &1 > start and &1 <= start + 3)
      if Enum.empty?(connections) do
        1
      else
        res = connections
        |> Enum.map(fn c -> p2_helper(Enum.drop_while(jolts, & &1 <= c), c) end)
        |> Enum.sum
        Memo.update(start, res)
        res
      end
    end
  end
end
