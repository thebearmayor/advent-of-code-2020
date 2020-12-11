import AOC

aoc 2019, 3 do
  def p1 do
    [wire1, wire2] = wires()
    |> Tuple.to_list
    |> Enum.map(& process_path(&1))
    |> Enum.map(fn {{_x, _y}, _steps, set} -> set |> Map.keys |> Enum.into(MapSet.new) end)

    MapSet.intersection(wire1, wire2)
    # |> MapSet.delete({0, 0})
    # |> IO.inspect
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min
  end

  # def input_string do "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83" end
  def p2 do
    [wire1, wire2] = wires()
    |> Tuple.to_list
    |> Enum.map(& process_path(&1))
    |> Enum.map(fn {{_x, _y}, _steps, set} -> set end)

    MapSet.intersection(Map.keys(wire1) |> Enum.into(MapSet.new),Map.keys(wire2) |> Enum.into(MapSet.new))
    |> Enum.map(fn int -> wire1[int] + wire2[int] end)
    |> Enum.min
  end

  def process_path(wire) do
    Enum.reduce(wire, {{0, 0}, 0, Map.new()}, &process_segment/2)
  end

  def process_segment({:U, dist}, {{x, y}, steps, points}) do
    new_points = 1 .. dist
    |> Enum.map(& {{x, y + &1}, steps + &1})
    |> Enum.into(%{})
    |> Map.merge(points)

    {{x, y + dist}, steps + dist, new_points}
  end

  def process_segment({:D, dist}, {{x, y}, steps, points}) do
    new_points = 1 .. dist
    |> Enum.map(& {{x, y - &1}, steps + &1})
    |> Enum.into(%{})
    |> Map.merge(points)

    {{x, y - dist}, steps + dist, new_points}
  end

  def process_segment({:R, dist}, {{x, y}, steps, points}) do
    new_points = 1 .. dist
    |> Enum.map(& {{x + &1, y}, steps + &1})
    |> Enum.into(%{})
    |> Map.merge(points)

    {{x + dist, y}, steps + dist, new_points}
  end

  def process_segment({:L, dist}, {{x, y}, steps, points}) do
    new_points = 1 .. dist
    |> Enum.map(& {{x - &1, y}, steps + &1})
    |> Enum.into(%{})
    |> Map.merge(points)

    {{x - dist, y}, steps + dist, new_points}
  end

  def wires do
    {path1, path2} = input_string()
    |> String.split("\n", trim: true)
    |> Enum.map(& String.split(&1, ","))
    |> List.to_tuple

    path1 = path1 |> Enum.map(&parse_segment/1)
    path2 = path2 |> Enum.map(&parse_segment/1)

    {path1, path2}
  end

  def parse_segment(seg) do
    dir = String.first(seg)
    dist = String.slice(seg, 1..-1) |> String.to_integer()
    {String.to_atom(dir), dist}
  end
end
