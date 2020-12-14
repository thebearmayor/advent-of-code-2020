import AOC

aoc 2020, 14 do
  use Bitwise
  def p1 do
    input_stream()
    |> Enum.map(&process_line/1)
    |> Enum.reduce({"", Map.new()}, &run_command/2)
    |> elem(1)
    |> Map.values()
    |> Enum.sum()
  end

  def process_line(line) do
    re = ~r/^(?<command>\w+)(?:\[(?<address>\d+)\])? = (?<target>.+)$/
    captures = Regex.named_captures(re, line)
    captures
  end

  def run_command(%{"command" => "mask", "address" => _address, "target" => target}, {_mask, mem}) do
    {target, mem}
  end

  def run_command(%{"command" => "mem", "address" => address, "target" => target}, {mask, mem}) do
    masked_target = mask(target, mask)
    {mask, Map.put(mem, address, masked_target)}
  end

  def mask(target, mask) do
    target = target |> String.to_integer() |> Integer.to_string(2) |> String.pad_leading(36, "0")

    Enum.zip(String.graphemes(mask), String.graphemes(target))
    |> Enum.reduce("", fn {m, t}, acc ->
      case m do
        "0" -> acc <> "0"
        "1" -> acc <> "1"
        "X" -> acc <> t
      end
    end)
    |> String.to_integer(2)
  end

  def p2 do
    input_stream()
    |> Enum.map(&process_line/1)
    |> Enum.reduce({"", Map.new()}, &run_command2/2)
    |> elem(1)
    |> Map.values()
    |> Enum.sum()
  end

  def mask_address(address, mask) do
    address =
      address |> String.to_integer() |> Integer.to_string(2) |> String.pad_leading(36, "0")

    Enum.zip(String.graphemes(mask), String.graphemes(address))
    |> Enum.reduce("", fn {m, t}, acc ->
      case m do
        "0" -> acc <> t
        "1" -> acc <> "1"
        "X" -> acc <> "X"
      end
    end)
    |> handle_floating_bits
  end

  # Slow, string-based solution.
  # def handle_floating_bits(address) do
  #   {bit, rest} = String.split_at(address, 1)

  #   case bit do
  #     "X" ->
  #       case rest do
  #         "" -> ["0", "1"] |> MapSet.new()
  #         _ -> handle_floating_bits(rest) |> Enum.flat_map(fn (addr) -> {"0"<>addr, "1"<>addr} end)
  #       end
  #     n -> handle_floating_bits(rest) |> Enum.map(fn (addr) -> n<>addr end)
  #   end
  # end

  def handle_floating_bits(""), do: [0]
  def handle_floating_bits("0"<>address), do: Enum.map(handle_floating_bits(address), & &1 <<< 1)
  def handle_floating_bits("1"<>address), do: Enum.map(handle_floating_bits(address), & (&1 <<< 1) + 1)
  def handle_floating_bits("X"<>address), do: Enum.flat_map(handle_floating_bits(address), &[&1 <<< 1, (&1 <<< 1) + 1])

  def run_command2(%{"command" => "mask", "address" => _address, "target" => target}, {_mask, mem}) do
    {target, mem}
  end

  def run_command2(%{"command" => "mem", "address" => address, "target" => target}, {mask, mem}) do
    addresses = mask_address(address, mask)
    mem = addresses
    |> Enum.reduce(mem, fn (addr, m) -> Map.put(m, addr, String.to_integer(target)) end)
    {mask, mem}
  end
end
