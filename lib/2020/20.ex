import AOC

aoc 2020, 20 do
  # use Backtrex

  def p1 do
    corners()
    |> Enum.map(& elem(&1, 0))
    |> Enum.reduce(& &1 * &2)
  end

  def corners do
    edges = edges()
    edges
    |> Enum.filter(fn tile ->
      Enum.count(edges, fn tile2 -> (MapSet.intersection(elem(tile, 1), elem(tile2, 1)) |> MapSet.size()) > 0 end) < 4
    end)
  end

  def edges do
    input_string()
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&parse_block/1)
    |> Enum.map(&tile_edges/1)
  end

  def parse_block(block) do
    {title, body} = String.split(block, "\n") |> List.pop_at(0)
    id = Regex.run(~r/\d+/, title) |> List.first() |> String.to_integer()
    {id, body}
  end

  def tile_edges({id, tile}) do
    top = List.first(tile)
    bottom = List.last(tile)
    left = Enum.map(tile, &String.first/1) |> Enum.join()
    right = Enum.map(tile, &String.last/1) |> Enum.join()
    edges = [top, bottom, left, right] |> Enum.flat_map(& [&1, String.reverse(&1)]) |> MapSet.new()
    {id, edges}
  end

  # Backtrex callbacks

  def p2 do
  end
end

# defmodule Picture do
#   defstruct tile, placed: %{}, remaining: MapSet.new()


# end
