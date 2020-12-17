import AOC

aoc 2019, 8 do
  def p1 do
    layer = layers() |> Enum.min_by(fn layer ->  Enum.count(layer, & &1 == "0") end)
    Enum.count(layer, & &1 == "1") * Enum.count(layer, & &1 == "2")
  end

  def layers, do: input_string() |> String.trim |> String.graphemes |> Enum.chunk_every(150)

  def find_visible(pixels), do: Enum.find(pixels, & &1 != "2")

  def p2 do
    0..149
    |> Enum.map(fn index -> Enum.map(layers(), & Enum.at(&1, index)) end)
    |> Enum.map(&find_visible/1)
    |> Enum.join()
  end
end
