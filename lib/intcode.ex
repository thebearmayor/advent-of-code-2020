defmodule Intcode do
  def parse_string(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Stream.with_index()
    |> Stream.map(fn {e, i} -> {i, String.to_integer(e)} end)
    |> Enum.into(%{})
  end

  def input(opcodes, input) do
    Map.put(opcodes, :input, input)
  end

  def run(opcodes, pos \\ 0) do
    # IO.inspect(opcodes)
    inst = opcodes[pos]
    oper = Integer.mod(inst, 100)
    # |> IO.inspect(label: "oper")
    params = div(inst, 100) |> Integer.digits() |> Enum.reverse()

    case oper do
      1 -> run_add(opcodes, pos, get_params(opcodes, params, (pos + 1)..(pos + 2)), opcodes[pos + 3])
      2 -> run_mul(opcodes, pos, get_params(opcodes, params, (pos + 1)..(pos + 2)), opcodes[pos + 3])
      3 -> run_sto(opcodes, pos, opcodes[pos + 1])
      4 -> run_get(opcodes, pos, get_params(opcodes, params, (pos + 1)..(pos + 1)))
      5 -> run_jmp_if_true(opcodes, pos, get_params(opcodes, params, pos+1..pos+2))
      6 -> run_jmp_if_false(opcodes, pos, get_params(opcodes, params, pos+1..pos+2))
      7 -> run_less_than(opcodes, pos, get_params(opcodes, params, pos+1..pos+2), opcodes[pos + 3])
      8 -> run_equals(opcodes, pos, get_params(opcodes, params, pos+1..pos+2), opcodes[pos + 3])
      99 -> run_halt(opcodes, pos)
    end
  end

  def get_params(opcodes, params, range) do
    range
    |> Enum.with_index()
    |> Enum.map(fn {pos, i} -> {pos, Enum.at(params, i, 0)} end)
    # |> IO.inspect()
    |> Enum.map(fn {pos, mode} ->
      case mode do
        0 -> opcodes[opcodes[pos]]
        1 -> opcodes[pos]
      end
    end)
  end

  def run_add(opcodes, pos, [op1, op2] = params, tgt) do
    # IO.inspect(params, label: "params")
    # IO.inspect(tgt, label: "tgt")
    op_size = 4
    run(Map.put(opcodes, tgt, op1 + op2), pos + op_size)
  end

  def run_mul(opcodes, pos, [op1, op2] = params, tgt) do
    # IO.inspect(params)
    op_size = 4
    run(Map.put(opcodes, tgt, op1 * op2), pos + op_size)
  end

  def run_sto(opcodes, pos, tgt) do
    # IO.inspect(tgt, label: "sto tgt")
    op_size = 2
    input = opcodes.input |> IO.inspect(label: "input")
    run(Map.put(opcodes, tgt, input), pos + op_size)
  end

  def run_get(opcodes, pos, [tgt]) do
    op_size = 2
    IO.inspect(tgt, label: "output")
    run(opcodes, pos + op_size)
  end

  def run_jmp_if_true(opcodes, pos, [tst, tgt]) do
    op_size = 3
    pos = if tst != 0, do: tgt, else: pos + op_size
    run(opcodes, pos)
  end

  def run_jmp_if_false(opcodes, pos, [tst, tgt]) do
    op_size = 3
    pos = if tst == 0, do: tgt, else: pos + op_size
    run(opcodes, pos)
  end

  def run_less_than(opcodes, pos, [op1, op2], tgt) do
    op_size = 4
    res = if op1 < op2, do: 1, else: 0
    run(Map.put(opcodes, tgt, res), pos + op_size)
  end

  def run_equals(opcodes, pos, [op1, op2], tgt) do
    op_size = 4
    res = if op1 == op2, do: 1, else: 0
    run(Map.put(opcodes, tgt, res), pos + op_size)
  end

  def run_halt(opcodes, _pos) do
    opcodes
  end
end
