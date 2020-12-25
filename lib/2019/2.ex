import AOC

aoc 2019, 2 do
  def p1 do
    test(12, 2)
  end

  def test(noun, verb) do
    {:ok, pid} = IntcodeServer.start_link(input_string())
    IntcodeServer.set(pid, 1, noun)
    IntcodeServer.set(pid, 2, verb)
    IntcodeServer.run(pid)
    {:ok, res} = IntcodeServer.get(pid, 0)
    res
  end

  def p2 do
    {_, noun, verb} =
      for noun <- 0..99,
          verb <- 0..99 do
        {test(noun, verb), noun, verb}
      end
      |> Enum.find(fn {res, _noun, _verb} -> res == 19_690_720 end)

    100 * noun + verb
  end
end
