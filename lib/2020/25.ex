import AOC

aoc 2020, 25 do
  def p1 do
    [pkey1, pkey2] = input_string() |> String.split()
    |> Enum.map(&String.to_integer/1)

    iterations = Stream.iterate(1, & loop(&1, 7))
    |> Stream.with_index()
    loop_size1 = Enum.find(iterations, fn {el, _i} -> el == pkey1 end) |> elem(1)
    Stream.iterate(1, & loop(&1, pkey2)) |> Enum.at(loop_size1)
  end

  @divisor 20201227
  def loop(n, subject) do
    Integer.mod(n * subject, @divisor)
  end

  def p2 do
  end
end
