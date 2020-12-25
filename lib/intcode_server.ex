defmodule IntcodeServer do
  use GenServer

  ## Client API

  def start_link(input, opts \\ []),      do: GenServer.start_link(__MODULE__, input, opts)
  def run(server),                  do: GenServer.call(server, {:run})
  def dump(server),                 do: GenServer.call(server, {:dump})
  def set(server, addr, value),     do: GenServer.call(server, {:set, addr, value})
  def get(server, addr),            do: GenServer.call(server, {:get, addr})
  def input(server, value),         do: GenServer.cast(server, {:input, value})
  def register_input(server, fun) when is_function(fun), do: GenServer.call(server, {:input_callback, fun})
  def output(server),               do: GenServer.call(server, {:output})

  ## GenServer callbacks

  @impl true
  @spec init(binary) :: {:ok, %{inputs: Qex.t(), outputs: Qex.t(), pos: 0, state: :initializing}}
  def init(input) do
    opcodes = input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Stream.with_index()
    |> Stream.map(fn {e, i} -> {i, String.to_integer(e)} end)
    |> Enum.into(%{})
    |> Map.put(:inputs, Qex.new)
    |> Map.put(:outputs, Qex.new)
    |> Map.put(:pos, 0)
    |> Map.put(:state, :initializing)
    {:ok, opcodes}
  end

  @impl true
  def handle_call({:dump}, _from, opcodes), do: {:reply, opcodes, opcodes}
  def handle_call({:get, addr}, _from, opcodes), do: {:reply, Map.fetch(opcodes, addr), opcodes}
  def handle_call({:set, addr, value}, _from, opcodes), do: {:reply, :ok, Map.put(opcodes, addr, value)}
  def handle_call({:run}, _from, opcodes), do: {:reply, :ok, go(opcodes)}
  def handle_call({:output}, _from, opcodes) do
    case Map.get_and_update!(opcodes, :outputs, &Qex.pop/1) do
      {{:value, output}, opcodes} -> {:reply, output, opcodes}
      {:empty, _} -> {:reply, :empty, opcodes}
    end
  end

  @impl true
  def handle_cast({:input, value}, opcodes) do
    {:noreply, Map.update(opcodes, :inputs, Qex.new([value]), &Qex.push(&1, value))}
  end

  def handle_cast({:input_callback, fun}, _from, opcodes) when is_function(fun) do
    {:noreply, Map.put(opcodes, :input_callback, fun)}
  end

  ## Internal functions
  defp lookup_oper(1),  do: :add
  defp lookup_oper(2),  do: :mult
  defp lookup_oper(3),  do: :inp
  defp lookup_oper(4),  do: :outp
  defp lookup_oper(5),  do: :jmp_if_true
  defp lookup_oper(6),  do: :jmp_if_false
  defp lookup_oper(7),  do: :less_than
  defp lookup_oper(8),  do: :equals
  defp lookup_oper(99), do: :halt

  defp go(%{pos: pos} = opcodes) do
    opcodes = %{opcodes | state: :running}
    inst = opcodes[pos]
    oper = Integer.mod(inst, 100) |> lookup_oper
    modes = div(inst, 100) |> Integer.digits() |> Enum.reverse()

    go({oper, modes}, opcodes)
      # 1 -> run_add(opcodes, get_params(opcodes, modes, 2))
      # 2 -> run_mul(opcodes, get_params(opcodes, modes, 2))
      # 3 -> run_in(opcodes)
      # 4 -> run_out(opcodes, get_params(opcodes, modes, 1))
      # 5 -> run_jmp_if_true(opcodes, get_params(opcodes, modes, 2))
      # 6 -> run_jmp_if_false(opcodes, get_params(opcodes, modes, 2))
      # 7 -> run_less_than(opcodes, get_params(opcodes, modes, 2))
      # 8 -> run_equals(opcodes, get_params(opcodes, modes, 2))
      # 99 -> run_halt(opcodes)
    # end
  end

  defp go({:add, modes}, %{pos: pos} = opcodes) do
    op_size = 4
    {op1, op2} = get_params(opcodes, modes, 2)
    tgt = opcodes[pos + 3]
    opcodes
    |> Map.put(tgt, op1 + op2)
    |> Map.update!(:pos, & &1 + op_size)
    |> go()
  end

  defp go({:mult, modes}, %{pos: pos} = opcodes) do
    op_size = 4
    {op1, op2} = get_params(opcodes, modes, 2)
    tgt = opcodes[pos + 3]
    opcodes
    |> Map.put(tgt, op1 * op2)
    |> Map.update!(:pos, & &1 + op_size)
    |> go()
  end

  defp go({:inp, _modes}, %{pos: pos} = opcodes) do
    op_size = 2
    tgt = opcodes[pos + 1]
    # is this the same as get_and_update?
    case Qex.pop(opcodes[:inputs]) do
      {:empty, _} ->
        if fun = opcodes[:input_callback] do
          value = fun.()
          opcodes
          |> Map.update(:inputs, Qex.new([value]), &Qex.push(&1, value))
          |> go()
        else
          %{opcodes | state: :waiting}
        end
      {{:value, input}, rest} ->
        opcodes
        |> Map.put(tgt, input)
        |> Map.put(:inputs, rest)
        |> Map.update!(:pos, & &1 + op_size)
        |> go()
    end
  end

  defp go({:outp, modes}, opcodes) do
    op_size = 2
    {tgt} = get_params(opcodes, modes, 1)
    opcodes
    |> Map.update!(:outputs, & Qex.push(&1, tgt))
    |> Map.update!(:pos, & &1 + op_size)
    |> go()
  end

  defp go({:jmp_if_true, modes}, opcodes) do
    op_size = 3
    {tst, tgt} = get_params(opcodes, modes, 2)
    opcodes
    |> Map.update!(:pos, fn pos -> if tst != 0, do: tgt, else: pos + op_size end)
    |> go()
  end

  defp go({:jmp_if_false, modes}, opcodes) do
    op_size = 3
    {tst, tgt} = get_params(opcodes, modes, 2)
    opcodes
    |> Map.update!(:pos, fn pos -> if tst == 0, do: tgt, else: pos + op_size end)
    |> go()
  end

  defp go({:less_than, modes}, %{pos: pos} = opcodes) do
    op_size = 4
    {op1, op2} = get_params(opcodes, modes, 2)
    tgt = opcodes[pos + 3]
    res = if op1 < op2, do: 1, else: 0
    opcodes
    |> Map.put(tgt, res)
    |> Map.update!(:pos, & &1 + op_size)
    |> go()
  end

  defp go({:equals, modes}, %{pos: pos} = opcodes) do
    op_size = 4
    {op1, op2} = get_params(opcodes, modes, 2)
    tgt = opcodes[pos + 3]
    res = if op1 == op2, do: 1, else: 0
    opcodes
    |> Map.put(tgt, res)
    |> Map.update!(:pos, & &1 + op_size)
    |> go()
  end

  defp go({:halt, _modes}, opcodes) do
    %{opcodes | state: :halted}
  end

  defp get_params(%{pos: pos} = opcodes, modes, count) do
    pos + 1..pos + count
    |> Stream.zip(Stream.concat(modes, Stream.repeatedly(fn -> 0 end)))
    |> Enum.map(fn {pos, mode} ->
      case mode do
        0 -> opcodes[opcodes[pos]]
        1 -> opcodes[pos]
      end
    end)
    |> List.to_tuple()
  end
end
