import AOC

aoc 2019, 9 do
  def p1 do
    {{:value, out}, _} = Intcode.new(input_string()) |> Intcode.input(1) |> Intcode.run |> Intcode.output()
    out
  end


  def p2 do
    {{:value, out}, _} = Intcode.new(input_string()) |> Intcode.input(2) |> Intcode.run |> Intcode.output()
    out
  end
end
