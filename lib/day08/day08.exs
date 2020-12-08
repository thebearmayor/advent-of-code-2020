defmodule Day08 do
  def parse_input do
    File.read!("input")
    |> String.split("\n", trim: true)
    |> Enum.map(&(&1 |> String.split() |> List.to_tuple()))
    |> Enum.map(fn {op, count} -> {String.to_atom(op), String.to_integer(count)} end)
    # |> IO.inspect()
    |> Enum.with_index()
    |> Enum.map(fn {{op, count}, index} -> {index, {op, count}} end)
    |> Enum.into(%{})
  end

  def start_program(program) do
    run_program(program, 0, MapSet.new, 0)
  end

  def run_program(program, index, seen, acc) do
    cond do
      MapSet.member?(seen, index) ->
        {:err, acc}

      !program[index] ->
        {:ok, acc}

      true ->
        seen = MapSet.put(seen, index)

        case program[index] do
          {:acc, count} -> run_program(program, index + 1, seen, acc + count)
          {:jmp, count} -> run_program(program, index + count, seen, acc)
          {:nop, _} -> run_program(program, index + 1, seen, acc)
        end
    end
  end

  def try_programs(initial) do
    initial
    |> Enum.map(fn ({index, {op, count}}) ->
      case op do
        :acc -> {:err, 0}
        :jmp -> start_program(Map.put(initial, index, {:nop, count}))
        :nop -> start_program(Map.put(initial, index, {:jmp, count}))
      end
    end)
  end
end

program = Day08.parse_input()

program
|> Day08.run_program(0, MapSet.new(), 0)
|> IO.inspect(label: "part 1")

program
|> Day08.try_programs
|> Enum.filter(&match?({:ok, _}, &1))
|> IO.inspect(label: "part 2")
