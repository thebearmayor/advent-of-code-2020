input = File.read!("input")
lines = String.split(input, "\n")

defmodule Part01 do
  def conform?(line) do
    [range, char, password] = String.split(line)
    char = String.first(char)
    [low, high] = String.split(range, "-") |> Enum.map(fn i -> String.to_integer(i) end)
    count = password |> String.graphemes |> Enum.count(fn c -> c == char end)
    low <= count and count <= high
  end
end

lines |> Enum.filter(fn l -> l != "" end) |> Enum.count(fn l -> Part01.conform?(l) end) |> IO.puts

defmodule Part02 do
  def conform?(line) do
    [range, char, password] = String.split(line)
    char = String.first(char)
    [low, high] = String.split(range, "-") |> Enum.map(fn i -> String.to_integer(i) end)
    lowChar = password |> String.graphemes |> Enum.at(low - 1)
    highChar = password |> String.graphemes |> Enum.at(high - 1)
    lowChar != highChar and (lowChar == char or highChar == char)
  end
end

lines |> Enum.filter(fn l -> l != "" end) |> Enum.count(fn l -> Part02.conform?(l) end) |> IO.puts
