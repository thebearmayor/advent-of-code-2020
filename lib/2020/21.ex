import AOC

aoc 2020, 21 do
#   def input_string, do:
# """
# mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
# trh fvjkl sbzzf mxmxvkd (contains dairy)
# sqjhc fvjkl (contains soy)
# sqjhc mxmxvkd sbzzf (contains fish)
# """

  def p1 do
    foods = input_string()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)

    allergens = foods |> Enum.reduce(fn (element, acc) -> Map.merge(acc, element, fn _k, v1, v2 -> MapSet.intersection(v1, v2) end) end)

    bad_ingredients = Map.values(allergens) |> Enum.reduce(&MapSet.union/2)
    ingredients = Enum.flat_map(foods, &Map.values/1) |> Enum.reduce(&MapSet.union/2)
    good_ingredients = MapSet.difference(ingredients, bad_ingredients)
    freqs = input_string() |> String.split() |> Enum.frequencies()
    good_ingredients |> Enum.reduce(0, fn el, acc -> acc + freqs[el] end)

  end

  def parse_line(line) do
    [ingredients, allergens] = line
    |> String.replace(~r/[\(\),]/, "")
    |> String.split("contains")
    |> Enum.map(fn part -> String.split(part) |> MapSet.new() end)

    Enum.map(allergens, & {&1, ingredients}) |> Map.new()
  end

  def p2 do
    foods = input_string()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)

    allergens = foods |> Enum.reduce(fn (element, acc) -> Map.merge(acc, element, fn _k, v1, v2 -> MapSet.intersection(v1, v2) end) end)

    bad_ingredients = Map.values(allergens) |> Enum.reduce(&MapSet.union/2)
    ingredients = Enum.flat_map(foods, &Map.values/1) |> Enum.reduce(&MapSet.union/2)
    good_ingredients = MapSet.difference(ingredients, bad_ingredients)
    freqs = input_string() |> String.split() |> Enum.frequencies()
    good_ingredients |> Enum.reduce(0, fn el, acc -> acc + freqs[el] end)
    a = for {allergens, ingredients} <- allergens, into: %{}, do: {allergens, MapSet.difference(ingredients, good_ingredients)}
    solve(a)
  end

  def solve(allergens, solved \\ %{})
  def solve(allergens, solved) when map_size(allergens) == 0 do
    Enum.sort(solved)
    |> Enum.map(& elem(&1, 1))
    |> Enum.join(",")
  end

  def solve(allergens, solved) do
    IO.inspect({allergens, solved})
    {allergen, ingredient} = Enum.find(allergens, & MapSet.size(elem(&1, 1)) == 1)
    ingredient = Enum.at(ingredient, 0)
    allergens = for {key, ingredients} <- allergens, key != allergen, into: %{}, do: {key, MapSet.delete(ingredients, ingredient)}
    solve(allergens, Map.put(solved, allergen, ingredient))
  end
end
