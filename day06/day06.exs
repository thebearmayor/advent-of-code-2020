groups = File.read!("input") |> String.trim |> String.split("\n\n")

# Part 1
groups |> Enum.map(fn g ->
  g
  |> String.graphemes
  |> Enum.reject(& &1 == "\n")
  |> MapSet.new()
  |> Enum.count() end)
  |> Enum.sum
  |> IO.puts

# Part 2
groups
  |> Enum.map(fn group ->
    group
    |> String.split
    |> Enum.map(fn person ->
      person
      |> String.graphemes
      |> MapSet.new
    end)
    |> Enum.reduce(& (MapSet.intersection(&1, &2)))
    |> Enum.count
  end)
  |> Enum.sum
  |> IO.puts
