# import AOC

# aoc 2020, 24 do
#   def p1 do
#     starting_layout()
#     |> MapSet.size()
#   end

#   @offsets %{
#     'e' => {1, -1, 0},
#     'se' => {0, -1, 1},
#     'sw' => {-1, 0, 1},
#     'w' => {-1, 1, 0},
#     'nw' => {0, 1, -1},
#     'ne' => {1, 0, -1}
#   }

#   def starting_layout do
#     input_stream()
#     |> Enum.map(&directions_to_hex/1)
#     |> Enum.reduce(MapSet.new, fn (tile, tiles) ->
#       if MapSet.member?(tiles, tile), do: MapSet.delete(tiles, tile), else: MapSet.put(tiles, tile)
#     end)
#   end

#   def directions_to_hex(dirs) do
#     {:ok, tokens, _} = :hex_lexer.string(to_charlist(dirs))
#     Enum.reduce(tokens, {0, 0, 0}, &move/2)
#   end

#   def move({:direction, _, dir}, {x, y, z}) do
#     {dx, dy, dz} = @offsets[dir]
#     {x + dx, y + dy, z + dz}
#   end

#   def neighbors({x, y, z}) do
#     @offsets
#     |> Map.values()
#     |> Enum.map(fn {dx, dy, dz} -> {x + dx, y + dy, z + dz} end)
#   end

#   def split_neighbors(tile, tiles) do
#     neighbors(tile)
#     |> Enum.split_with(& MapSet.member?(tiles, &1))
#   end

#   def next_day(tiles) do
#     {next_black, seen_white} =
#       tiles
#       |> Enum.reduce({MapSet.new(), []}, fn (tile, {next_black, seen_white}) ->
#         {black, white} = split_neighbors(tile, tiles)
#         next_black = if Enum.count(black) == 0 or Enum.count(black) > 2, do: next_black, else: MapSet.put(next_black, tile)
#         seen_white = white ++ seen_white
#         {next_black, seen_white}
#       end)
#     next_black = (for {tile, count} <- Enum.frequencies(seen_white),
#         count == 2,
#         into: MapSet.new(),
#         do: tile)
#     |> MapSet.union(next_black)
#     next_black
#   end

#   def p2 do
#     starting_layout()
#     |> Stream.iterate(&next_day/1)
#     |> Enum.at(100)
#     |> Enum.count
#   end
# end
