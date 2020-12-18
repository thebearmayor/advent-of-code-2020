import AOC

aoc 2020, 17 do
  def p1 do
    Stream.iterate(parse_input(), &advance/1)
    |> Enum.at(6)
    |> Enum.count(& elem(&1, 1) == :active)
  end

  def parse_input() do
    input_stream()
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, j} ->
        case char do
          "." -> {{i, j, 0}, :inactive}
          "#" -> {{i, j, 0}, :active}
        end
      end)
    end)
    |> Enum.into(%{})
  end

  def advance(state) do
    for x <- -10..15,
        y <- -10..15,
        z <- -10..15,
        into: %{} do
          cube = Map.get(state, {x, y, z})
          active = case cube do
            :active -> case active_neighbors({x, y, z}, state) do
              2 -> :active
              3 -> :active
              _ -> :inactive
            end
            _ -> case active_neighbors({x, y, z}, state) do
              3 -> :active
              _ -> :inactive
            end
          end
          {{x, y, z}, active}
        end
  end

  def active_neighbors({x, y, z} = loc, state) do
    for i <- x - 1 .. x + 1,
        j <- y - 1 .. y + 1,
        k <- z - 1 .. z + 1,
        {i, j, k} != loc do
          Map.get(state, {i, j, k})
        end
    |> Enum.count(& &1 == :active)
  end

  def p2 do
    Stream.iterate(parse_input2(), &advance2/1)
    |> Enum.at(6)
    |> Enum.count(& elem(&1, 1) == :active)
  end

  def parse_input2() do
    input_stream()
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, i} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, j} ->
        case char do
          "." -> {{i, j, 0, 0}, :inactive}
          "#" -> {{i, j, 0, 0}, :active}
        end
      end)
    end)
    |> Enum.into(%{})
  end

  def advance2(state) do
    for existing <- Map.keys(state),
        loc <- neighbors(existing),
        into: %{} do
          cube = Map.get(state, loc)
          active = case cube do
            :active -> case active_neighbors2(loc, state) do
              2 -> :active
              3 -> :active
              _ -> :inactive
            end
            _ -> case active_neighbors2(loc, state) do
              3 -> :active
              _ -> :inactive
            end
          end
          {loc, active}
        end
  end

  def neighbors({x, y, z, a} = loc) do
    for i <- x - 1 .. x + 1,
        j <- y - 1 .. y + 1,
        k <- z - 1 .. z + 1,
        l <- a - 1 .. a + 1,
        {i, j, k, l} != loc,
        do: {i, j, k, l}
  end
  def active_neighbors2(loc, state) do
    Enum.map(neighbors(loc), fn neighbor -> Map.get(state, neighbor) end)
    |> Enum.count(& &1 == :active)
  end
end
