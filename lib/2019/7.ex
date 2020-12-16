import AOC

aoc 2019, 7 do
  def p1 do
    program = input_string()

    phases =
      for a <- 0..4,
          b <- 0..4,
          c <- 0..4,
          d <- 0..4,
          e <- 0..4,
          MapSet.new([a, b, c, d, e]) == MapSet.new(0..4),
          do: run_all({a, b, c, d, e}, program)

    phases
    |> Enum.max()
  end

  def run_amp(input, phase, program \\ input_string()) do
    IO.inspect(input, label: "input")
    IO.inspect(phase, label: "phase")
    intcode = Intcode.parse_string(program)

    intcode
    |> Intcode.input(phase)
    |> Intcode.input(input)
    |> Intcode.run()
    |> Intcode.output()
    |> Qex.first!()
  end

  def run_all({a, b, c, d, e}, program) do
    run_amp(0, a, program)
    |> run_amp(b, program)
    |> run_amp(c, program)
    |> run_amp(d, program)
    |> run_amp(e, program)
  end

  # def input_string,
  #   do:
  #     "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"

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
