import AOC

aoc 2020, 12 do
  def p1 do
    parse()
    |> solve({{0, 0}, 90}, &move/2)
  end

  def p2 do
    parse()
    |> solve({{0, 0}, {1, 10}}, &movew/2)
  end

  def parse do
    input_stream()
    |> Enum.map(fn inst ->
      {inst, val} = String.split_at(inst, 1)
      {inst, String.to_integer(val)}
    end)
  end

  def solve(instructions, ship, fun) do
    {{y, x}, _} = Enum.reduce(instructions, ship, fun)
    abs(y) + abs(x)
  end

  def move({"N", val}, {{y, x} = _pos, facing}) do
    {{y + val, x}, facing}
  end

  def move({"S", val}, {{y, x} = _pos, facing}) do
    {{y - val, x}, facing}
  end

  def move({"E", val}, {{y, x} = _pos, facing}) do
    {{y, x + val}, facing}
  end

  def move({"W", val}, {{y, x} = _pos, facing}) do
    {{y, x - val}, facing}
  end

  def move({"R", val}, {pos, facing}) do
    {pos, Integer.mod(facing + val, 360)}
  end

  def move({"L", val}, {pos, facing}) do
    {pos, Integer.mod(facing - val, 360)}
  end

  def move({"F", val}, {_pos, 0} = ship) do
    move({"N", val}, ship)
  end

  def move({"F", val}, {_pos, 90} = ship) do
    move({"E", val}, ship)
  end

  def move({"F", val}, {_pos, 180} = ship) do
    move({"S", val}, ship)
  end

  def move({"F", val}, {_pos, 270} = ship) do
    move({"W", val}, ship)
  end

  def movew({"N", val}, {ship, {y, x} = _point}) do
    {ship, {y + val, x}}
  end

  def movew({"S", val}, {ship, {y, x} = _point}) do
    {ship, {y - val, x}}
  end

  def movew({"E", val}, {ship, {y, x} = _point}) do
    {ship, {y, x + val}}
  end

  def movew({"W", val}, {ship, {y, x} = _point}) do
    {ship, {y, x - val}}
  end

  def movew({"R", val}, {ship, {y, x} = _point}) do
    case div(val, 90) do
      1 -> {ship, {-x, y}}
      2 -> {ship, {-y, -x}}
      3 -> {ship, {x, -y}}
    end
  end

  def movew({"R", 90}, {ship, {y, x} = _point}) do
    {ship, {-x, y}}
  end

  def movew({"R", 180}, {ship, {y, x} = _point}) do
    {ship, {-y, -x}}
  end

  def movew({"R", 270}, {ship, {y, x} = _point}) do
    {ship, {x, -y}}
  end

  def movew({"L", val}, {ship, point}) do
    movew({"R", 360 - val}, {ship, point})
  end

  def movew({"F", val}, {{i, j} = _ship, {y, x} = point}) do
    {{i + y * val, j + x * val}, point}
  end
end
