import AOC

aoc 2019, 1 do
  def p1 do
    simple_fuel_for_modules()
  end

  def p2 do
    fuel_for_modules()
  end

  def simple_fuel_for_modules do
    input_stream()
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&formula/1)
    |> Enum.sum
  end

  def fuel_for_modules do
    input_stream()
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&fuel_for_mass/1)
    |> Enum.sum
  end

  def fuel_for_mass(mass) do
    formula(mass)
    |> Stream.iterate(&formula/1)
    |> Stream.take_while(& &1 >= 0)
    |> Enum.sum
  end

  def formula(mass) do
    div(mass, 3) - 2
  end
end
