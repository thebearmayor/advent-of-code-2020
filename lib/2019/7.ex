import AOC

aoc 2019, 7 do
  def p1 do
    phases =
      for a <- 0..4,
          b <- 0..4,
          c <- 0..4,
          d <- 0..4,
          e <- 0..4,
          MapSet.new([a, b, c, d, e]) == MapSet.new(0..4) do
            run_servers([a, b, c, d, e])
          end

    phases
    |> Enum.max()
  end

  def run_servers([a, b, c, d, e]) do
    [ia, ib, ic, id, ie] =
      [a, b, c, d, e]
      |> Enum.map(fn phase ->
        {:ok, pid} = IntcodeServer.start_link(input_string())
        IntcodeServer.input(pid, phase)
        pid
      end)
    IntcodeServer.input(ia, 0)
    IntcodeServer.register_input(ia, fn -> IntcodeServer.output(ie) end)
    IntcodeServer.register_input(ib, fn -> IntcodeServer.output(ia) end)
    IntcodeServer.register_input(ic, fn -> IntcodeServer.output(ib) end)
    IntcodeServer.register_input(id, fn -> IntcodeServer.output(ic) end)
    IntcodeServer.register_input(ie, fn -> IntcodeServer.output(id) end)
    [ia, ib, ic, id, ie]
    |> Enum.map(&IntcodeServer.run/1)
    IntcodeServer.output(ie)
  end

# TODO: wire them up together
  def p2 do
    phases =
      for a <- 5..9,
          b <- 5..9,
          c <- 5..9,
          d <- 5..9,
          e <- 5..9,
          MapSet.new([a, b, c, d, e]) == MapSet.new(5..9) do
        [a, b, c, d, e] |> Enum.map(&init/1) |> List.to_tuple()
      end

    phases
    |> Enum.map(fn {a, b, c, d, e} ->
      a = Intcode.input(a, 0)
      run({a, b, c, d, e})
    end)
    |> Enum.max()
  end

  def run({a, b, c, d, e}) do
    a = Intcode.run(a)
    {out, a} = Intcode.output(a)
    b = Intcode.input(b, out)
    b = Intcode.run(b)
    {out, b} = Intcode.output(b)
    c = Intcode.input(c, out)
    c = Intcode.run(c)
    {out, c} = Intcode.output(c)
    d = Intcode.input(d, out)
    d = Intcode.run(d)
    {out, d} = Intcode.output(d)
    e = Intcode.input(e, out)
    e = Intcode.run(e)
    {out, e} = Intcode.output(e)

    case Intcode.state(e) do
      :halted ->
        out

      _ ->
        a = Intcode.input(a, out)
        run({a, b, c, d, e})
    end
  end

  def init(phase, program \\ input_string()) do
    program
    |> Intcode.parse_string()
    |> Intcode.input(phase)
  end
end
