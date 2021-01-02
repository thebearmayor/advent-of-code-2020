import AOC

aoc 2019, 11 do
  def p1 do
    intcode = Intcode.new(input_string())
    step({intcode, %{}, {0, 0}, 0}) |> map_size()
  end

  def step({intcode, panels, {x, y}, direction}) do
    case Intcode.halted?(intcode) do
      true ->
        panels

      false ->
        color = Map.get(panels, {x, y}, 0)

        {{:value, [new_color, rotation]}, intcode} =
          Intcode.input(intcode, color) |> Intcode.run() |> Intcode.drain()

        rotation = if rotation == 0, do: -1, else: 1
        new_direction = Integer.mod(direction + rotation * 90, 360)
        {new_x, new_y} = move({x, y}, new_direction)
        step {intcode, Map.put(panels, {x, y}, new_color), {new_x, new_y}, new_direction}
    end
  end

  def move({x, y}, 0), do: {x, y - 1}
  def move({x, y}, 90), do: {x + 1, y}
  def move({x, y}, 180), do: {x, y + 1}
  def move({x, y}, 270), do: {x - 1, y}

  def p2 do
    intcode = Intcode.new(input_string())
    panels = step({intcode, %{{0, 0} => 1}, {0, 0}, 0})
    out = Enum.map(0..5, fn y ->
      Enum.map(0..42, fn x ->
        if Map.get(panels, {x, y}, 0) == 1, do: "\u2588", else: " "
      end) |> Enum.join("")
    end) |> Enum.join("\n")
    IO.puts(out)
  end
end
