import AOC

aoc 2019, 4 do
  def p1 do
    {min, max} = range()
    min..max
    |> Stream.map(&Integer.to_string/1)
    |> Stream.filter(&consecutive_digits?/1)
    |> Stream.reject(&decreasing_digits?/1)
    |> Enum.count()
  end

  def p2 do
    {min, max} = range()
    min..max
    |> Stream.map(&Integer.to_string/1)
    |> Stream.filter(&only_two_consecutive_digits?/1)
    |> Stream.reject(&decreasing_digits?/1)
    |> Enum.count()
  end

  def range do
    input_string() |> String.trim |> String.split("-") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end

  def consecutive_digits?(n) do
    digits?(n, fn [x, y] -> x == y end)
  end

  def decreasing_digits?(n) do
    digits?(n, fn [x, y] -> y < x end)
  end

  def digits?(n, fun) do
    n
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fun)
  end

  def only_two_consecutive_digits?(n) do
    [a, b, c, d, e, f] = String.graphemes(n)
    (a == b and b != c)
    or (a != b and b == c and c != d)
    or (b != c and c == d and d != e)
    or (c != d and d == e and e != f)
    or (d != e and e == f)

  end
end
