defmodule Intcode do
  defstruct opcodes: %{}, pos: 0, state: :init
  @opaque t :: %__MODULE__{opcodes: %{opcodes: %{integer => integer}, pos: integer, state: atom}}

  @spec new(binary) :: Intcode.t()
  def new(string) do
    opcodes =
      string
      |> String.trim()
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Map.new(fn {el, i} -> {i, el} end)

    %Intcode{opcodes: opcodes}
  end

  @spec run(Intcode.t()) :: Intcode.t()
  def run(%Intcode{state: :halt} = intcode), do: intcode
  def run(%Intcode{state: :init} = intcode), do: %{intcode | state: :run} |> run
  def run(intcode), do: intcode |> step |> run

  @spec step(Intcode.t()) :: Intcode.t()
  def step(%Intcode{pos: pos, opcodes: opcodes} = intcode) do
    # IO.puts(intcode)
    op = opcodes[pos]

    case op do
      1 -> binary_op_and_store(intcode, &Kernel.+/2)
      2 -> binary_op_and_store(intcode, &Kernel.*/2)
      99 -> halt(intcode)
    end
  end

  @spec binary_op_and_store(Intcode.t(), (integer, integer -> integer)) :: Intcode.t()
  def binary_op_and_store(%Intcode{pos: pos} = intcode, fun) when is_function(fun) do
    op_size = 4
    [op1, op2, tgt] = params(intcode, (pos + 1)..(pos + 3), [0, 0, 1])

    intcode
    |> store(tgt, fun.(op1, op2))
    |> advance(op_size)
  end

  def halt(intcode) do
    %{intcode | state: :halt}
  end

  def params(intcode, locs, modes) do
    Enum.zip(locs, modes)
    |> Enum.map(fn {loc, mode} ->
      case mode do
        0 ->
          addr = intcode.opcodes[loc]
          intcode.opcodes[addr]

        1 ->
          intcode.opcodes[loc]
      end
    end)
  end

  @spec store(Intcode.t(), integer, integer) :: Intcode.t()
  def store(intcode, tgt, val) when is_integer(tgt) and is_integer(val) do
    put_in(intcode.opcodes[tgt], val)
  end

  @spec fetch(Intcode.t(), integer) :: integer
  def fetch(intcode, tgt) when is_integer(tgt) do
    intcode.opcodes[tgt]
  end

  @spec advance(Intcode.t(), integer) :: Intcode.t()
  def advance(intcode, step) when is_integer(step), do: update_in(intcode.pos, &(&1 + step))

  defimpl String.Chars do
    def to_string(intcode) do
      intcode.opcodes
      |> Enum.sort()
      |> Enum.map(fn {pos, val} ->
        val = Integer.to_string(val)
        if pos == intcode.pos, do: IO.ANSI.format([:bright, :yellow, val]), else: val
      end)
      |> Enum.join(",")
    end

  end
end
