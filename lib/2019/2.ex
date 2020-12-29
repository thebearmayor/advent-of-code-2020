import AOC

aoc 2019, 2 do
  def p1 do
    test(12, 2)
  end

  def test(noun, verb) do
    Intcode.new(input_string())
    |> Intcode.store(1, noun)
    |> Intcode.store(2, verb)
    |> Intcode.run()
    |> Intcode.fetch(0)
  end

  def p2 do
    # {noun, verb} =
    #   for noun <- 0..99,
    #       verb <- 0..99,
    #       test(noun, verb) == 19_690_720 do
    #       {noun, verb}
    #   end
    #   |> List.first
    {noun, verb} =
      Stream.flat_map(
        0..99,
        fn n ->
          Stream.flat_map(0..99, fn v ->
            [{n, v}]
          end)
        end)
        |> Enum.find(fn {n, v} -> test(n, v) == 19_690_720 end)

    100 * noun + verb
  end
end
