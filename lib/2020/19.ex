import AOC

aoc 2020, 19 do
  def p1 do
    rules = parse_rules()
    messages = parse_messages()
    matcher = Regex.compile!("^" <> rule_to_regex(rules, rules[0]) <> "$")
    messages |> Enum.count(& Regex.match?(matcher, &1))
  end

  def parse_rules do
    input_stream()
    |> Stream.take_while(&(&1 != ""))
    |> Stream.map(&parse_rule/1)
    |> Enum.into(%{})
  end

  def parse_messages do
    input_stream()
    |> Stream.drop_while(&(&1 != ""))
    |> Stream.filter(&(&1 != ""))
  end

  def parse_rule(line) do
    {:ok, tokens, _} = :rule_lexer.string(String.to_charlist(line))
    {:ok, rule} = :rule_parser.parse(tokens)
    rule
  end

  def rule_to_regex(rules, rule) do
    case rule do
      'a' -> "a"
      'b' -> "b"
      {[42], [42, 8]} -> "(" <> rule_to_regex(rules, [42]) <> ")+"
      {[42, 31], [42, 11, 31]} -> "(?<rule11>" <> rule_to_regex(rules, [42]) <> "(?&rule11)?" <> rule_to_regex(rules, [31]) <> ")"
      {l, r} -> "(" <> rule_to_regex(rules, l) <> "|" <>rule_to_regex(rules, r) <> ")"
      ns when is_list(ns) -> Enum.reduce(ns, "", fn (n, acc) -> acc <> rule_to_regex(rules, rules[n]) end)
    end
  end

  def p2 do
    rules = parse_rules()
    |> Map.put(8, {[42], [42, 8]})
    |> Map.put(11, {[42, 31], [42, 11, 31]})
    messages = parse_messages()
    matcher = Regex.compile!("^" <> rule_to_regex(rules, rules[0]) <> "$")
    messages |> Enum.count(& Regex.match?(matcher, &1))
  end
end
