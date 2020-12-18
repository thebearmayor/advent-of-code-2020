import AOC

aoc 2020, 18 do
  def p1 do
    input_stream()
    |> Stream.map(& parse(&1, :exp_parser))
    |> Stream.map(&eval/1)
    |> Enum.sum()
  end

  def parse(line, parser) do
    case :exp_lexer.string(String.to_charlist(line)) do
      {:ok, tokens, _} ->
        case parser.parse(tokens) do
          {:ok, ast} -> ast
          {:error, reason} -> exit(reason)
        end

      {:error, reason, _} ->
        exit(reason)
    end
  end

  def eval({:int, _, i}), do: i
  def eval({:plus, op1, op2}), do: (eval(op1) + eval(op2))
  def eval({:mult, op1, op2}), do: (eval(op1) * eval(op2))

  def p2 do
    input_stream()
    |> Stream.map(& parse(&1, :exp_parser_precedence))
    |> Stream.map(&eval/1)
    |> Enum.sum()
  end
end
