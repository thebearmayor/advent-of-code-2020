import AOC

aoc 2019, 10 do
  def p1 do
    map = parse(input_string())

    Enum.map(map.asteroids, fn station -> slopes(station, map.asteroids) end)
    |> Enum.max
  end

  def slope({sx, sy}, {ax, ay}) do
    dx = ax - sx
    dy = ay - sy
    gcd = Integer.gcd(dx, dy)
    {div(dx, gcd), div(dy, gcd)}
  end

  def slopes(station, asteroids) do
    unique_slopes = for asteroid <- asteroids,
        station != asteroid,
        into: MapSet.new(),
        do: slope(station, asteroid)
    MapSet.size(unique_slopes)
  end

  defstruct asteroids: MapSet.new(), size: 0

  def parse(input) do
    lines = String.split(input)
    size = length(lines)

    asteroids =
      for {line, y} <- Enum.with_index(lines),
          {asteroid, x} <- String.graphemes(line) |> Enum.with_index(),
          asteroid == "#",
          into: MapSet.new(),
          do: {x, y}

    %__MODULE__{asteroids: asteroids, size: size}
  end

  def p2 do
    map = parse(input_string())

    station = Enum.max_by(map.asteroids, fn station -> slopes(station, map.asteroids) end)
    normalized = for asteroid = {ax, ay} <- map.asteroids,
        station != asteroid do
          {sx, sy} = station
          {ax - sx, ay - sy}
        end

    polar = Enum.map(normalized, &convert/1) |> Enum.sort(&sorter/2)
    {_, _, {x, y}} = sort(polar, -1, []) |> Enum.at(199)
    {sx, sy} = station
    (x + sx) * 100 + (y + sy)
  end

  def convert({x, y}) do
    r = :math.sqrt(:math.pow(y, 2) + :math.pow(x, 2))
    theta = :math.atan2(x, -y)
    theta = if theta >= 0.0, do: theta, else: theta + 2 * :math.pi
    {theta, r, {x, y}}
  end

  def sorter({theta1, r1, _}, {theta2, r2, _}) do
    if theta1 == theta2, do: r1 <= r2, else: theta1 <= theta2
  end

  def sort([], _, acc), do: Enum.reverse(acc)
  def sort(asteroids, last_theta, acc) do
    case Enum.drop_while(asteroids, fn {theta, _, _} -> theta <= last_theta end) |> List.first() do
      nil -> sort(asteroids, -1, acc)
      next -> sort(List.delete(asteroids, next), elem(next, 0), [next | acc])
    end
  end
end
