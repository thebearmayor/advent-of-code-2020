import AOC

aoc 2020, 23 do
  def p1 do
    input_string()
    |> String.trim()
    |> String.to_integer()
    |> Integer.digits()
    |> Zipper.from_list()
    |> Stream.iterate(& move(&1, 9))
    |> Enum.at(100)
    # |> score
  end

  def input_string, do: "389125467"

  def move(cups, max) do
    {removed, cups} = cups |> Zipper.remove_right(3)
    IO.inspect(removed, label: "move - removed")

    dest = cond do
      cups.curr != 1 and Enum.any?(cups.curr - 1 .. 1, & !Enum.member?(removed, &1)) -> Enum.find(cups.curr - 1 .. 1, & !Enum.member?(removed, &1))
      true -> Enum.find(max .. cups.curr + 1, & !Enum.member?(removed, &1))
    end
    require IEx; IEx.pry
    Zipper.insert_right_to(cups, removed, dest)
  end

  # def score(cups) do
  #   rotate_to(cups, 1)
  #   |> drop()
  #   |> zip_to_list()
  #   |> Integer.undigits()
  # end


  def p2 do
  end
end
