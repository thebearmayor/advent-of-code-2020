import AOC

aoc 2019, 7 do
  def p1 do
    (for [a, b, c, d, e] <- permute(Enum.into(0..4, [])), do: run_servers([a, b, c, d, e]))
    |> Enum.max()
  end

  def permute([]), do: [[]]
  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x|y]
  end

  def run_servers(phases) do
    [a, b, c, d, e] = Enum.map(phases, & Intcode.new(input_string()) |> Intcode.input(&1))
    # a = Intcode.input(a, 0)
    {{:value, outa}, _} = Intcode.input(a, 0) |> Intcode.run() |> Intcode.output()
    {{:value, outb}, _} = Intcode.input(b, outa) |> Intcode.run() |> Intcode.output()
    {{:value, outc}, _} = Intcode.input(c, outb) |> Intcode.run() |> Intcode.output()
    {{:value, outd}, _} = Intcode.input(d, outc) |> Intcode.run() |> Intcode.output()
    {{:value, oute}, _} = Intcode.input(e, outd) |> Intcode.run() |> Intcode.output()
    oute
  end

  def p2 do
    (for [a, b, c, d, e] <- permute(Enum.into(5..9, [])), do: loop_servers([a, b, c, d, e]))
    |> Enum.max()
  end

  def loop_servers(phases) do
    [a, b, c, d, e] = Enum.map(phases, & Intcode.new(input_string()) |> Intcode.input(&1))
    a = Intcode.input(a, 0)
    loop_servers_([a, b, c, d, e])
  end

  def loop_servers_([a, b, c, d, e]) do
    {{:value, outa}, a} = Intcode.run(a) |> Intcode.output()
    {{:value, outb}, b} = Intcode.input(b, outa) |> Intcode.run() |> Intcode.output()
    {{:value, outc}, c} = Intcode.input(c, outb) |> Intcode.run() |> Intcode.output()
    {{:value, outd}, d} = Intcode.input(d, outc) |> Intcode.run() |> Intcode.output()
    {{:value, oute}, e} = Intcode.input(e, outd) |> Intcode.run() |> Intcode.output()

    case Intcode.halted?(e) do
      false ->
        a = Intcode.input(a, oute)
        loop_servers_([a, b, c, d, e])
      true ->
        oute
    end
  end
end
