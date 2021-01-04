import AOC

aoc 2019, 13 do
  def p1 do
    {{:value, output}, _} = Intcode.new(input_string()) |> Intcode.run |> Intcode.drain

    output
    |> Enum.chunk_every(3)
    |> Enum.count(fn [_, _, id] -> id == 2 end)
  end

  def p2 do
    start = Intcode.new(input_string()) |> Intcode.store(0, 2)
    play(start, %{})
  end

  def play(intcode, state) do
    {{:value, output}, next} = intcode |> Intcode.run() |> Intcode.drain()
    state = process(state, output)
    num_blocks = state |> Map.values |> Enum.count(& &1 == 2)
    ball = state |> Enum.find(& elem(&1, 1) == 4) |> elem(0) |> elem(0)
    paddle = state |> Enum.find(& elem(&1, 1) == 3) |> elem(0) |> elem(0)
    score = state |> Map.get({-1,0}, 0)

    cond do
      num_blocks == 0 -> score
      ball < paddle  -> play(Intcode.input(next, -1), state)
      ball == paddle -> play(Intcode.input(next,  0), state)
      ball > paddle  -> play(Intcode.input(next,  1), state)
    end
  end

  def process(state, output) do
    # IO.inspect(output, limit: :infinity)
    updates = output
    |> Enum.chunk_every(3)
    # |> IO.inspect(label: "objects")
    |> Enum.map(fn [x, y, id] -> {{x, y}, id} end)
    |> Enum.into(%{})

    Map.merge(state, updates)
  end
end
