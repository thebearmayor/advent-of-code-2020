defmodule Intcode do

  def parse_string(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Stream.with_index()
    |> Stream.map(fn {e, i} -> {i, String.to_integer(e)} end)
    |> Enum.into(%{})
    |> Map.put(:inputs, Qex.new)
    |> Map.put(:outputs, Qex.new)
    |> Map.put(:pos, 0)
    |> Map.put(:state, :initializing)
  end

  def input(opcodes, input) do
    Map.update(opcodes, :inputs, Qex.new([input]), &Qex.push(&1, input))
  end

  def output(opcodes) do
    {{:value, value}, opcodes} = Map.get_and_update!(opcodes, :outputs, &Qex.pop/1)
    {value, opcodes}
  end

  def state(opcodes) do
    opcodes[:state]
  end

  def run(%{pos: pos} = opcodes) do
    # IO.inspect(opcodes)
    inst = opcodes[pos]
    oper = Integer.mod(inst, 100)
    # |> IO.inspect(label: "oper")
    modes = div(inst, 100) |> Integer.digits() |> Enum.reverse()

    opcodes = %{opcodes | state: :running}
    case oper do
      1 -> run_add(opcodes, get_params(opcodes, modes, 2))
      2 -> run_mul(opcodes, get_params(opcodes, modes, 2))
      3 -> run_in(opcodes)
      4 -> run_out(opcodes, get_params(opcodes, modes, 1))
      5 -> run_jmp_if_true(opcodes, get_params(opcodes, modes, 2))
      6 -> run_jmp_if_false(opcodes, get_params(opcodes, modes, 2))
      7 -> run_less_than(opcodes, get_params(opcodes, modes, 2))
      8 -> run_equals(opcodes, get_params(opcodes, modes, 2))
      99 -> run_halt(opcodes)
    end
  end

  def get_params(%{pos: pos} = opcodes, modes, count) do
    pos + 1..pos + count
    |> Stream.zip(Stream.concat(modes, Stream.repeatedly(fn -> 0 end)))
    # |> IO.inspect()
    |> Enum.map(fn {pos, mode} ->
      case mode do
        0 -> opcodes[opcodes[pos]]
        1 -> opcodes[pos]
      end
    end)
  end

  def run_add(%{pos: pos} = opcodes, [op1, op2] = _params) do
    # IO.inspect(params, label: "params")
    # IO.inspect(tgt, label: "tgt")
    op_size = 4
    tgt = opcodes[pos + 3]
    opcodes
    |> Map.put(tgt, op1 + op2)
    |> Map.update!(:pos, & &1 + op_size)
    |> run()
  end

  def run_mul(%{pos: pos} = opcodes, [op1, op2] = _params) do
    # IO.inspect(params)
    op_size = 4
    tgt = opcodes[pos + 3]
    opcodes
    |> Map.put(tgt, op1 * op2)
    |> Map.update!(:pos, & &1 + op_size)
    |> run()
  end

  def run_in(%{pos: pos} = opcodes) do
    # IO.inspect(tgt, label: "sto tgt")
    op_size = 2
    tgt = opcodes[pos + 1]
    # {input, rest} = Qex.pop!(opcodes.inputs)
    case Qex.pop(opcodes.inputs) do
      {:empty, _} -> %{opcodes | state: :waiting}
      {{:value, input}, rest} ->
        opcodes
        |> Map.put(tgt, input)
        |> Map.put(:inputs, rest)
        |> Map.update!(:pos, & &1 + op_size)
        |> run()
    end
  end

  def run_out(opcodes, [tgt]) do
    op_size = 2
    # IO.inspect(tgt, label: "output")
    opcodes
    |> Map.update!(:outputs, & Qex.push(&1, tgt))
    |> Map.update!(:pos, & &1 + op_size)
    |> run()
  end

  def run_jmp_if_true(opcodes, [tst, tgt]) do
    op_size = 3
    opcodes
    |> Map.update!(:pos, fn pos ->  if tst != 0, do: tgt, else: pos + op_size end)
    |> run()
  end

  def run_jmp_if_false(opcodes, [tst, tgt]) do
    op_size = 3
    opcodes
    |> Map.update!(:pos, fn pos -> if tst == 0, do: tgt, else: pos + op_size end)
    |> run()
  end

  def run_less_than(%{pos: pos} = opcodes, [op1, op2]) do
    op_size = 4
    tgt = opcodes[pos + 3]
    res = if op1 < op2, do: 1, else: 0
    opcodes
    |> Map.put(tgt, res)
    |> Map.update!(:pos, & &1 + op_size)
    |> run()
  end

  def run_equals(%{pos: pos} = opcodes, [op1, op2]) do
    op_size = 4
    tgt = opcodes[pos + 3]
    res = if op1 == op2, do: 1, else: 0
    opcodes
    |> Map.put(tgt, res)
    |> Map.update!(:pos, & &1 + op_size)
    |> run()
  end

  def run_halt(opcodes) do
    %{opcodes | state: :halted}
  end
end
