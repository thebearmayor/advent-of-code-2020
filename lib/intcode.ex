defmodule Intcode do
  def parse_string(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Stream.map(fn {e, i} -> {i, e} end)
    |> Enum.into(%{})
  end

  def run(opcodes, pos) do
    case opcodes[pos] do
      1 -> run_add(opcodes, pos)
      2 -> run_mul(opcodes, pos)
      99 -> run_halt(opcodes, pos)
    end
  end

  def run_add(opcodes, pos) do
    op_size = 4
    op1 = opcodes[opcodes[pos + 1]]
    op2 = opcodes[opcodes[pos + 2]]
    tgt = opcodes[pos + 3]
    run(Map.put(opcodes, tgt, op1 + op2), pos + op_size)
  end

  def run_mul(opcodes, pos) do
    op_size = 4
    op1 = opcodes[opcodes[pos + 1]]
    op2 = opcodes[opcodes[pos + 2]]
    tgt = opcodes[pos + 3]
    run(Map.put(opcodes, tgt, op1 * op2), pos + op_size)
  end

  def run_halt(opcodes, _pos) do
    opcodes
  end
end
