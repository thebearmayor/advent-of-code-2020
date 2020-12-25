import AOC

aoc 2019, 5 do
  def p1 do
    {:ok, pid} = IntcodeServer.start_link(input_string())
    IntcodeServer.input(pid, 1)
    IntcodeServer.run(pid)
    # require IEx; IEx.pry
    Stream.repeatedly(fn -> IntcodeServer.output(pid) end) |> Enum.find(& &1 != 0)
  end

  def p2 do
    {:ok, pid} = IntcodeServer.start_link(input_string())
    IntcodeServer.input(pid, 5)
    IntcodeServer.run(pid)
    # require IEx; IEx.pry
    Stream.repeatedly(fn -> IntcodeServer.output(pid) end) |> Enum.find(& &1 != 0)
  end
end
