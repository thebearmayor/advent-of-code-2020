import AOC

aoc 2019, 6 do
  def p1 do
    parse() |> count_bodies
  end

#   def input_stream do
#     "COM)B
# B)C
# C)D
# D)E
# E)F
# B)G
# G)H
# D)I
# E)J
# J)K
# K)L" |> String.split()
#   end

  def parse do
    input_stream()
    |> Enum.map(fn s ->
      [i, o] = String.split(s, ")")
      {o, i}
    end)
    |> Enum.into(%{})
  end

  def count_one_body(_orbits, "COM") do
    0
  end

  def count_one_body(orbits, body) do
    1 + count_one_body(orbits, orbits[body])
  end

  def count_bodies(orbits) do
    Map.keys(orbits)
    |> Enum.map(&count_one_body(orbits, &1))
    |> Enum.sum()
  end

#   def input_stream do
# "COM)B
# B)C
# C)D
# D)E
# E)F
# B)G
# G)H
# D)I
# E)J
# J)K
# K)L
# K)YOU
# I)SAN" |> String.trim |> String.split("\n")
#   end
  def p2 do
    orbits = parse()
    graph = build_graph()
    verts = :digraph.get_path(graph, orbits["YOU"], orbits["SAN"])
    |> Enum.count
    verts - 1
  end

  def build_graph(graph \\ :digraph.new) do
    edges = input_stream()
    |> Enum.map(fn line -> line |> String.split(")") end)
    Enum.map(edges, fn [v1, v2] ->
      :digraph.add_vertex(graph, v1)
      :digraph.add_vertex(graph, v2)
      :digraph.add_edge(graph, v1, v2)
      :digraph.add_edge(graph, v2, v1)
    end)
    :digraph.edges(graph)
    graph
  end
end
