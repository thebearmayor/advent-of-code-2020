defmodule Rules do

  # dotted blue bags contain 5 wavy green bags, 3 pale beige bags.
  # dull lime bags contain 1 dotted olive bag, 3 dim brown bags.
  # mirrored magenta bags contain 3 mirrored gray bags, 2 plaid beige bags, 4 dull brown bags, 3 pale plum bags.
  # posh coral bags contain 2 light blue bags, 2 dotted purple bags, 1 pale fuchsia bag, 2 light cyan bags.
  # bright orange bags contain 2 shiny chartreuse bags.
  # plaid salmon bags contain 1 faded coral bag, 4 clear lavender bags, 5 wavy tan bags.
  def parse_rule(rule) do
    [outer, inner] = String.split(rule, " bags contain ")
    inner
    |> String.split(~r/ bags*(, |.)/, trim: true)
    |> Enum.map(& String.replace(&1, ~r/[0-9] /, ""))
    |> Enum.map(& {&1, MapSet.new([outer])})
    |> Enum.into(%{})
  end

  def parse_input(input) do
    input
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&parse_rule/1)
    |> Enum.reduce(fn x, y -> Map.merge(x, y, fn _k, v1, v2 ->
      MapSet.union(v1, v2)
    end) end)
  end

  def search(graph, start) do
    search_helper(graph, start, MapSet.new)
  end

  def search_helper(graph, curr, seen) do
    if !graph[curr] do
      seen
    else
      connected = MapSet.difference(graph[curr], seen)
      connected
      |> Enum.reduce(seen, & search_helper(graph, &1, MapSet.put(&2, &1)))
    end
  end

  # dotted blue bags contain 5 wavy green bags, 3 pale beige bags.
  # dull lime bags contain 1 dotted olive bag, 3 dim brown bags.
  # mirrored magenta bags contain 3 mirrored gray bags, 2 plaid beige bags, 4 dull brown bags, 3 pale plum bags.
  # posh coral bags contain 2 light blue bags, 2 dotted purple bags, 1 pale fuchsia bag, 2 light cyan bags.
  # bright orange bags contain 2 shiny chartreuse bags.
  # plaid salmon bags contain 1 faded coral bag, 4 clear lavender bags, 5 wavy tan bags.
  def parse_rule2(rule) do
    if String.contains?(rule, "no other bags") do
      %{}
    else
      [outer, inner] = String.split(rule, " bags contain ")
      connections = inner
      |> String.split(~r/ bags*(, |.)/, trim: true)
      |> Enum.map(& String.split(&1, " ", parts: 2))
      |> Enum.map(fn v ->
        [count, color] = v
        {color, String.to_integer(count)}
      end)
      %{outer => connections}
    end
  end

  def parse_input2(input) do
    input
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&parse_rule2/1)
    |> Enum.reduce(&Map.merge/2)
  end

  def search2(graph, start) do
    search_helper2(graph, start, 0)
  end

  def search_helper2(graph, curr, acc) do
    if !graph[curr] do
      acc
    else
      graph[curr]
      |> Enum.reduce(acc, fn el, acc ->
        {color, weight} = el
        acc + weight * search_helper2(graph, color, 1)
      end)

    end
  end
end

input = File.read!("input")
input
|> Rules.parse_input
|> Rules.search("shiny gold")
|> Enum.count
|> IO.inspect

input
|> Rules.parse_input2
|> Rules.search2("shiny gold")
|> IO.inspect
