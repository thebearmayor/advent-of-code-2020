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
end
