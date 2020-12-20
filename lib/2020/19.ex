import AOC

aoc 2020, 19 do
  def p1 do
    rules = parse_rules()
    messages = parse_messages()
    messages |> Enum.count(&check(&1, rules))
  end

  # def input_stream do
  #   File.read!("input/2020_19_test.txt")
  #   |> String.trim()
  #   |> String.split("\n")
  #   |> Enum.map(&String.trim/1)
  # end

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

  # def verify(string, rules, rule_number) do
  #   IO.inspect({string, rules[rule_number]})
  #   case rules[rule_number] do
  #     char when char == 'a' or char == 'b' -> String.to_charlist(string) == char
  #     num when is_number(num) -> verify(string, rules, num)
  #     [n0, n1] -> verify(String.at(string, 0), rules, n0) and verify(String.slice(string, 1..-1), rules, n1)
  #     {r0, r1} -> veryify(string, )
  #   end
  # end

  def check(string, rules, pos \\ 0) do
    case verify(string, rules, rules[pos]) do
      {:ok, matched} when matched == string -> true
      _ -> false
    end
  end

  def verify(string, _rules, char) when char == 'a' or char == 'b' do
    # IO.inspect{string, char, label: "char"}
    first_char = String.at(string, 0)
    if first_char == to_string(char), do: {:ok, first_char}, else: {:nok}
  end

  def verify(string, rules, [n]) when is_number(n), do: verify(string, rules, rules[n])

  def verify(string, rules, ns) when is_list(ns) do
    # IO.inspect({string, ns, label: "nums"})

    Enum.reduce(ns, {:ok, ""}, fn (n, acc) ->
      # IO.inspect(n, label: "n")
      # IO.inspect(acc, label: "acc")
      case acc do
        {:ok, matched} ->
          rest = String.slice(string, String.length(matched)..-1)

          case verify(rest, rules, rules[n]) do
            {:ok, new_match} -> {:ok, matched <> new_match}
            _ -> {:nok}
          end

        _ ->
          {:nok}
      end
    end)
  end

  # def verify(string, rules, [n0, n1]) when is_number(n0) and is_number(n1) do
  #   # IO.inspect{string, [n0, n1], label: "nums"}
  #   case verify(string, rules, rules[n0]) do
  #     {:ok, matched} ->
  #       case verify(String.slice(string, String.length(matched)..-1), rules, rules[n1]) do
  #         {:ok, matched2} -> {:ok, matched <> matched2}
  #         {:nok} -> {:nok}
  #       end
  #     {:nok} -> {:nok}
  #   end
  # end

  # def verify(string, rules, [n0, n1, n2]) when is_number(n0) and is_number(n1) and is_number(n2) do
  #   IO.inspect{string, [n0, n1, n2], label: "nums"}
  #   case verify(string, rules, rules[n0]) do
  #     {:ok, matched} ->
  #       case verify(String.slice(string, String.length(matched)..-1), rules, rules[n1]) do
  #         {:ok, matched2} -> case verify(String.slice(string, String.length(matched) + String.length(matched2)..-1), rules, rules[n2]) do
  #           {:ok, matched3} -> {:ok, matched <> matched2 <> matched3}
  #           {:nok} -> {:nok}
  #         end
  #         {:nok} -> {:nok}
  #       end
  #     {:nok} -> {:nok}
  #   end
  # end

  def verify(string, rules, {r0, r1}) when is_list(r0) and is_list(r1) do
    # IO.inspect{string, {r0, r1}, label: "rules"}
    case verify(string, rules, r1) do
      {:ok, matched} -> {:ok, matched}
      {:nok} -> verify(string, rules, r0)
    end
  end

  def p2 do
    rules =
      parse_rules()
      |> Map.put(8, {[42], [42, 8]})
      |> Map.put(11, {[42, 31], [42, 11, 31]})
      |> IO.inspect()

    messages = parse_messages()
    messages |> Enum.count(&check(&1, rules))
  end
end
