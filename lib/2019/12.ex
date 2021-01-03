import AOC

aoc 2019, 12 do
  def p1 do
    input_string()
    |> parse
    |> Stream.iterate(&step/1)
    |> Enum.at(1000)
    |> total_energy
  end

  def parse(input) do
    for line <- input |> String.trim() |> String.split("\n") do
      [x, y, z] =
        Regex.run(~r/<x=([-+\d]+), y=([-+\d]+), z=([-+\d]+)>/, line, capture: :all_but_first)

      %{pos: {String.to_integer(x), String.to_integer(y), String.to_integer(z)}, vel: {0, 0, 0}}
    end
  end

  def step(moons) do
    moons
    |> Enum.map(&update_vel(&1, moons))
    |> Enum.map(&update_pos/1)
  end

  def step_single(moons) do
    moons
    |> Enum.map(&update_vel_single(&1, moons))
    |> Enum.map(&update_pos_single/1)
  end

  def update_vel(moon = %{pos: {x, y, z}}, moons) do
    for other = %{pos: {ox, oy, oz}} <- moons,
        other != moon,
        reduce: moon do
      moon ->
        Map.update!(moon, :vel, fn {vx, vy, vz} ->
          {vx + compare(x, ox), vy + compare(y, oy), vz + compare(z, oz)}
        end)
    end
  end

  def update_vel_single(moon, moons) do
    for other <- moons,
        other != moon,
        reduce: moon do
      moon ->
        vel = compare(elem(moon, 0), elem(other, 0)) + elem(moon, 1)
        put_elem(moon, 1, vel)
    end
  end

  def compare(x1, x2) do
    case x2 - x1 do
      n when n < 0 -> -1
      n when n == 0 -> 0
      n when n > 0 -> 1
    end
  end

  def update_pos(%{vel: {dx, dy, dz}} = moon),
    do: Map.update!(moon, :pos, fn {x, y, z} -> {x + dx, y + dy, z + dz} end)

  def update_pos_single({x, dx}), do: {x + dx, dx}

  def total_energy(moons) do
    moons
    |> Enum.map(fn %{pos: {x, y, z}, vel: {vx, vy, vz}} ->
      (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
    end)
    |> Enum.sum()
  end

  def p2 do
    moons =
      input_string()
      |> parse

    [x_steps, y_steps, z_steps] =
      Enum.map(0..2, fn axis ->
        moons = moons
        |> Enum.map(&to_single(&1, axis))

        1 + (step_single(moons)
        |> Stream.iterate(&step_single/1)
        |> Enum.find_index(& &1 == moons))

      end)

    lcm(x_steps, lcm(y_steps, z_steps))
  end

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, Integer.gcd(a, b))

  def to_single(moon, axis), do: {elem(moon.pos, axis), elem(moon.vel, axis)}
end
