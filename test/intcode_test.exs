defmodule IntcodeTest do
  use ExUnit.Case
  doctest Intcode

  setup do
    string = "1,9,10,3,2,3,11,0,99,30,40,50"
    intcode = Intcode.new(string)
    %{intcode: intcode}
  end

  test "parses input string", context do
    expected = %Intcode{
      pos: 0,
      opcodes: %{
        0 => 1,
        1 => 9,
        2 => 10,
        3 => 3,
        4 => 2,
        5 => 3,
        6 => 11,
        7 => 0,
        8 => 99,
        9 => 30,
        10 => 40,
        11 => 50
      }
    }

    assert context[:intcode] == expected
  end

  test "adds", context do
    expected = %Intcode{
      pos: 4,
      opcodes: %{
        0 => 1,
        1 => 9,
        2 => 10,
        3 => 70,
        4 => 2,
        5 => 3,
        6 => 11,
        7 => 0,
        8 => 99,
        9 => 30,
        10 => 40,
        11 => 50
      }
    }

    assert Intcode.step(context[:intcode]) == expected
  end

  test "multiplies", context do
    intcode = context[:intcode]
    intcode = %{intcode | pos: 4}

    expected = %Intcode{
      pos: 8,
      opcodes: %{
        0 => 150,
        1 => 9,
        2 => 10,
        3 => 3,
        4 => 2,
        5 => 3,
        6 => 11,
        7 => 0,
        8 => 99,
        9 => 30,
        10 => 40,
        11 => 50
      }
    }

    assert Intcode.step(intcode) == expected
  end

  test "halts", context do
    intcode = context[:intcode]
    intcode = %{intcode | pos: 8}

    expected = %Intcode{
      pos: 8,
      state: :halt,
      opcodes: %{
        0 => 1,
        1 => 9,
        2 => 10,
        3 => 3,
        4 => 2,
        5 => 3,
        6 => 11,
        7 => 0,
        8 => 99,
        9 => 30,
        10 => 40,
        11 => 50
      }
    }

    assert Intcode.step(intcode) == expected
  end

  test "runs until halt", context do
    intcode = context[:intcode]
    expected = %Intcode{
      pos: 8,
      state: :halt,
      opcodes: %{
        0 => 3500,
        1 => 9,
        2 => 10,
        3 => 70,
        4 => 2,
        5 => 3,
        6 => 11,
        7 => 0,
        8 => 99,
        9 => 30,
        10 => 40,
        11 => 50
      }
    }

    assert Intcode.run(intcode) == expected
  end

  test "stores", context do
    intcode = context[:intcode]
    expected = %Intcode{
      pos: 0,
      opcodes: %{
        0 => 1,
        1 => 9,
        2 => 12,
        3 => 3,
        4 => 2,
        5 => 3,
        6 => 11,
        7 => 0,
        8 => 99,
        9 => 30,
        10 => 40,
        11 => 50
      }
    }

    assert Intcode.store(intcode, 2, 12) == expected
  end

  test "fetches", context do
    intcode = context[:intcode]
    expected = 11
    assert Intcode.fetch(intcode, 6) == expected
  end

  test "stores input" do
    intcode = Intcode.new("3,50")
    input = 2345
    expected = input
    actual =
      intcode
      |> Intcode.input(input)
      |> Intcode.step()
      |> Intcode.fetch(50)
    assert actual == expected
  end

  test "produces output" do
    intcode = Intcode.new("4,50")
    output = 5678
    expected = output
    {{:value, actual}, _} =
      intcode
      |> Intcode.store(50, output)
      |> Intcode.step()
      |> Intcode.output

    assert actual == expected
  end

  test "interprets parameter modes" do
    intcode = Intcode.new("1002,4,3,4,33")
    expected = 99
    actual =
      intcode
      |> Intcode.run()
      |> Intcode.fetch(4)

    assert actual == expected
  end

  test "jumps" do
    # output 0 if input is 0
    intcode = Intcode.new("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9")
    {{:value, actual}, _} = intcode
    |> Intcode.input(0)
    |> Intcode.run()
    |> Intcode.output()
    assert actual == 0

  end

  test "jumps and comparisons" do
    intcode = Intcode.new("3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99")

    # output 999 if input less than 8
    {{:value, actual}, _} = intcode
    |> Intcode.input(6)
    |> Intcode.run()
    |> Intcode.output()
    assert actual == 999

    # output 1001 if input greater than 8
    {{:value, actual}, _} = intcode
    |> Intcode.input(20)
    |> Intcode.run()
    |> Intcode.output()
    assert actual == 1001
  end
end
