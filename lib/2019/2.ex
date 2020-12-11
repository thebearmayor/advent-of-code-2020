import AOC

aoc 2019, 2 do
  def p1 do
    input_string()
    |> Intcode.parse_string()
    |> Map.put(1, 12)
    |> Map.put(2, 2)
    |> Intcode.run(0)
    |> Map.get(0)
  end

  def p2 do
    mem = input_string() |> Intcode.parse_string()
    out =
      for noun <- 0..99,
          verb <- 0..99 do
        res = mem
        |> Map.put(1, noun)
        |> Map.put(2, verb)
        |> Intcode.run(0)
        {res, noun, verb}
      end
    out
    |> Enum.find(fn {mem, _noun, _verb} -> mem[0] == 19690720 end)
    |> (fn {_mem, noun, verb} -> (100 * noun) + verb end).()

  # def input_string do "1,9,10,3,2,3,11,0,99,30,40,50" end
  end
end
