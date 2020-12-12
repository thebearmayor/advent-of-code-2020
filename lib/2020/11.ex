import AOC

aoc 2020, 11 do
  def p1 do
    p1_helper(make_layout())
  end

  def p1_helper(layout) do
    new_layout =
      for {seat, _} <- layout,
          into: %{},
          do: {seat, update_seat(seat, layout, 4, &find_occupied_neighbors/2)}

    if Map.equal?(layout, new_layout) do
      count_occupied(Map.values(new_layout))
    else
      p1_helper(new_layout)
    end
  end

  def p2 do
      p2_helper(make_layout())
  end

  def p2_helper(layout) do
    new_layout =
      for {seat, _} <- layout,
          into: %{},
          do: {seat, update_seat(seat, layout, 5, &find_visible_occupied_neighbors/2)}

    if Map.equal?(layout, new_layout) do
      count_occupied(Map.values(new_layout))
    else
      p2_helper(new_layout)
    end
  end

  def make_layout do
    for {line, y} <- input_string() |> String.trim() |> String.split() |> Enum.with_index(),
        {char, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      case char do
        "L" -> {{y, x}, :unoccupied}
        "." -> {{y, x}, :floor}
      end
    end
  end

  def update_seat(seat, layout, capacity, fun) do
    occupied_neighbors = fun.(seat, layout) |> count_occupied

    case layout[seat] do
      :occupied when occupied_neighbors >= capacity -> :unoccupied
      :unoccupied when occupied_neighbors == 0 -> :occupied
      x -> x
    end
  end

  def find_occupied_neighbors({y, x}, layout) do
    for i <- (y - 1)..(y + 1),
        j <- (x - 1)..(x + 1),
        i != y or j != x do
      Map.get(layout, {i, j})
    end
  end

  def find_visible_occupied_neighbors(seat, layout) do
    [
      fn {i, j} -> {i - 1, j - 1} end,
      fn {i, j} -> {i - 1, j} end,
      fn {i, j} -> {i - 1, j + 1} end,
      fn {i, j} -> {i, j + 1} end,
      fn {i, j} -> {i + 1, j + 1} end,
      fn {i, j} -> {i + 1, j} end,
      fn {i, j} -> {i + 1, j - 1} end,
      fn {i, j} -> {i, j - 1} end
    ]
    |> Enum.map(&find_visible_neighbor(seat, layout, &1))
  end

  def find_visible_neighbor(seat, layout, dir) do
    case layout[dir.(seat)] do
      :floor -> find_visible_neighbor(dir.(seat), layout, dir)
      nil -> nil
      x -> x
    end
  end

  defp count_occupied(seats), do: Enum.count(seats, fn seat -> seat == :occupied end)
end
