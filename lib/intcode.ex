defmodule Intcode do
  defstruct opcodes: %{}, pos: 0, state: :init, input: Qex.new(), output: Qex.new(), debug: false

  @opaque t :: %__MODULE__{
            opcodes: %{
              opcodes: %{integer => integer},
              pos: integer,
              state: atom,
              input: Qex.t(),
              output: Qex.t(),
              debug: boolean
            }
          }

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
    if intcode.debug, do: IO.puts(intcode)
    op = Integer.mod(opcodes[pos], 100)

    case op do
      1 -> binary_op_and_store(intcode, &Kernel.+/2)
      2 -> binary_op_and_store(intcode, &Kernel.*/2)
      3 -> store_input(intcode)
      4 -> fetch_output(intcode)
      5 -> unary_jump(intcode, &(&1 != 0))
      6 -> unary_jump(intcode, &(&1 == 0))
      7 -> binary_op_and_store(intcode, &if(&1 < &2, do: 1, else: 0))
      8 -> binary_op_and_store(intcode, &if(&1 == &2, do: 1, else: 0))
      99 -> halt(intcode)
    end
  end

  @spec binary_op_and_store(Intcode.t(), (integer, integer -> integer)) :: Intcode.t()
  def binary_op_and_store(%Intcode{pos: pos} = intcode, fun) when is_function(fun) do
    op_size = 4
    [op1, op2] = params(intcode, (pos + 1)..(pos + 2))
    tgt = intcode.opcodes[pos + 3]

    intcode
    |> store(tgt, fun.(op1, op2))
    |> advance(op_size)
  end

  @spec unary_jump(Intcode.t(), (integer -> boolean)) :: Intcode.t()
  def unary_jump(%Intcode{pos: pos} = intcode, fun) when is_function(fun) do
    op_size = 3
    [op1, op2] = params(intcode, (pos + 1)..(pos + 2))
    if fun.(op1), do: jump(intcode, op2), else: advance(intcode, op_size)
  end

  @spec store_input(Intcode.t()) :: Intcode.t()
  def store_input(%Intcode{pos: pos, opcodes: opcodes} = intcode) do
    op_size = 2
    tgt = opcodes[pos + 1]

    {{:value, val}, input} = Qex.pop(intcode.input)

    %{intcode | input: input}
    |> store(tgt, val)
    |> advance(op_size)
  end

  @spec fetch_output(Intcode.t()) :: Intcode.t()
  def fetch_output(intcode) do
    op_size = 2
    val = params(intcode, intcode.pos + 1)
    output = Qex.push(intcode.output, val)

    %{intcode | output: output}
    |> advance(op_size)
  end

  @spec halt(Intcode.t()) :: Intcode.t()
  def halt(intcode) do
    %{intcode | state: :halt}
  end

  @spec params(Intcode.t(), integer | Enum.t()) :: integer | list(integer)
  def params(intcode, loc) when is_integer(loc), do: List.first(params(intcode, [loc]))

  def params(%Intcode{pos: pos, opcodes: opcodes} = intcode, locs) do
    modes =
      opcodes[pos]
      |> div(100)
      |> Integer.digits()
      |> Enum.reverse()
      |> Stream.concat(Stream.repeatedly(fn -> 0 end))

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

  @spec jump(Intcode.t(), integer) :: Intcode.t()
  def jump(intcode, tgt) when is_integer(tgt), do: %{intcode | pos: tgt}

  @spec input(Intcode.t(), integer) :: Intcode.t()
  def input(intcode, val) when is_integer(val), do: update_in(intcode.input, &Qex.push(&1, val))

  @spec output(Intcode.t()) :: {{:value, integer}, Intcode.t()}
  def output(intcode) do
    {val, output} = Qex.pop(intcode.output)
    {val, %{intcode | output: output}}
  end

  @spec drain(Intcode.t()) :: {{:value, [integer]}, Intcode.t()}
  def drain(intcode) do
    val = Enum.into(intcode.output, [])
    {{:value, val}, %{intcode | output: Qex.new()}}
  end

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
