defmodule TreeMap do
  def create(filename) do
    lines = File.read!(filename) |> String.trim |> String.split("\n")
    width = hd(lines) |> String.length
    height = lines |> Enum.count
    tree_map = for {row, x} <- Enum.with_index(lines),
        {col, y} <- row |> String.graphemes |> Enum.with_index, into: %{} do
          {{x, y}, (if col == "#", do: true, else: false)}
    end
    Map.merge(tree_map, %{width: width, height: height})
  end

  def get(tree_map, row, col) do
    # normalize the column
    y = Integer.mod(col, tree_map.width)
    # IO.puts y
    tree_map[{row, y}]
  end

  def travel(tree_map, row, col, dx, dy) do
    if row > tree_map.height do
      0
    else
      tree = if get(tree_map, row, col), do: 1, else: 0
      IO.puts "row: #{row}, col: #{col}, tree: #{tree}"
      tree + travel(tree_map, row + dx, col + dy, dx, dy)
    end
  end
end

tree_map = TreeMap.create("input")

for {dx, dy} <- [{1, 1}, {1, 3}, {1, 5}, {1, 7}, {2, 1}] do
  TreeMap.travel(tree_map, 0, 0, dx, dy)
end |> Enum.reduce(1, &(&1 * &2)) |> IO.puts
