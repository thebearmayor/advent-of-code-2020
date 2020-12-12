import AOC

aoc 2019, 5 do
  def p1 do
    input_string()
    |> Intcode.parse_string()
    |> Intcode.input(1)
    |> Intcode.run(0)
    nil
  end

  def p2 do
    input_string()
    |> run(5)
    nil
  end

  def run(prog, input) do
    prog |> Intcode.parse_string() |> Intcode.input(input) |> Intcode.run()
    nil
  end
end
