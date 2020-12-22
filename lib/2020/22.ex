import AOC

aoc 2020, 22 do
  def p1 do
    [deck1, deck2] =
      input_string()
      |> String.trim()
      |> String.split("\n\n")
      |> Enum.map(&parse_deck/1)

    winner = combat(deck1, deck2)
    score(winner)
  end

  def parse_deck(lines) do
    String.split(lines, "\n")
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.into(Qex.new())
  end

  def combat(d1, d2) do
    cond do
      Enum.empty?(d1) ->
        d2

      Enum.empty?(d2) ->
        d1

      true ->
        {card1, d1} = Qex.pop!(d1)
        IO.puts("Player 1 plays: #{card1}")
        {card2, d2} = Qex.pop!(d2)
        IO.puts("Player 2 plays: #{card2}")

        case card1 > card2 do
          true ->
            IO.puts("Player 1 wins the round")
            d1 = Qex.push(d1, card1) |> Qex.push(card2)
            combat(d1, d2)

          false ->
            IO.puts("Player 2 wins the round")
            d2 = Qex.push(d2, card2) |> Qex.push(card1)
            combat(d1, d2)
        end
    end
  end

  def score(deck) do
    Qex.reverse(deck)
    |> Enum.to_list()
    |> Enum.with_index(1)
    |> Enum.map(fn {el, i} -> el * i end)
    |> Enum.sum()
  end
  def p2 do
    [deck1, deck2] =
      input_string()
      |> String.trim()
      |> String.split("\n\n")
      |> Enum.map(&parse_deck/1)

    Memo.start_link()
    Memo.reset()
    winner = rc(deck1, deck2)

    case winner |> IO.inspect() do
      {:d1, d1, _} -> score(d1)
      {:d2, _, d2} -> score(d2)
    end
  end

  def rc(d1, d2, game \\ 1) do
    cond do
      Memo.get({d1, d2, game}) ->
        IO.puts("Game #{game} Player 1 wins (infinite loop)")
        {:d1, d1, d2}

      Enum.empty?(d1) ->
        IO.puts("Game #{game} Player 2 wins (empty deck)")
        {:d2, d1, d2}

        Enum.empty?(d2) ->
        IO.puts("Game #{game} Player 1 wins (empty deck)")
        {:d1, d1, d2}

      true ->
        Memo.update({d1, d2, game}, true)
        {card1, d1} = Qex.pop!(d1)
        {card2, d2} = Qex.pop!(d2)

        case rc_round(card1, card2, d1, d2, game) do
          :d1 ->
            d1 = Qex.push(d1, card1) |> Qex.push(card2)
            rc(d1, d2, game)

          :d2 ->
            d2 = Qex.push(d2, card2) |> Qex.push(card1)
            rc(d1, d2, game)
        end
    end
  end

  def rc_round(card1, card2, d1, d2, game) do
    if Enum.count(d1) < card1 or Enum.count(d2) < card2 do
      if card1 > card2 do
        # IO.puts("Game #{game} Player 1 wins the round (cannot recurse)")
        :d1
      else
        # IO.puts("Game #{game} Player 2 wins the round (cannot recurse)")
        :d2
      end
    else
      IO.puts("Game #{game} Starting sub-game")

      case rc(Enum.take(d1, card1) |> Qex.new(), Enum.take(d2, card2) |> Qex.new(), game + 1) do
        {:d1, _, _} ->
          # IO.puts("Game #{game} Player 1 wins the round")
          :d1

        {:d2, _, _} ->
          # IO.puts("Game #{game} Player 2 wins the round")
          :d2
      end
    end
  end

end
