import AOC

aoc 2019, 5 do
  def p1 do
    {{:value, output}, _} =
      Intcode.new(input_string())
    |> Intcode.input(1)
    |> Intcode.run()
    |> Intcode.drain()

    output
    |> Enum.find(& &1 != 0)
  end

  def p2 do
    {{:value, output}, _} =
    Intcode.new(input_string())
    |> Intcode.input(5)
    |> Intcode.run()
    |> Intcode.output()

    output
  end
end
