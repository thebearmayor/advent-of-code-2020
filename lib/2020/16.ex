import AOC

aoc 2020, 16 do
  def p1 do
    rules = parse_rules()
    tickets = parse_nearby_tickets()

    tickets
    |> List.flatten()
    |> Enum.reject(fn value ->
      Enum.any?(rules, fn rule ->
        (rule["low1"] <= value and value <= rule["high1"]) or
          (rule["low2"] <= value and value <= rule["high2"])
      end)
    end)
    |> Enum.sum()
  end

  def parse_rules do
    input_string()
    |> String.trim()
    |> String.split("\n\n")
    |> List.first()
    |> String.split("\n")
    |> Enum.map(
      &Regex.named_captures(
        ~r/^(?<field>.*): (?<low1>\d+)-(?<high1>\d+) or (?<low2>\d+)-(?<high2>\d+)$/,
        &1
      )
    )
    |> Enum.map(fn m ->
      m
      |> Map.update!("low1", &String.to_integer/1)
      |> Map.update!("high1", &String.to_integer/1)
      |> Map.update!("low2", &String.to_integer/1)
      |> Map.update!("high2", &String.to_integer/1)
    end)
  end

  def parse_nearby_tickets do
    input_string()
    |> String.trim()
    |> String.split("\n\n")
    |> List.last()
    |> String.split("\n")
    |> List.delete_at(0)
    |> Enum.map(&parse_ticket/1)
  end

  def parse_my_ticket do
    input_string()
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.at(1)
    |> String.split("\n")
    |> List.delete_at(0)
    |> Enum.map(&parse_ticket/1)
  end

  def parse_ticket(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def valid_ticket?(ticket, rules) do
    Enum.all?(ticket, fn value ->
      Enum.any?(rules, &valid_value?(value, &1))
    end)
  end

  def valid_value?(value, rule) do
    (rule["low1"] <= value and value <= rule["high1"]) or
      (rule["low2"] <= value and value <= rule["high2"])
  end

  def valid_column?(col, tickets, rule) do
    Enum.map(tickets, fn ticket -> Enum.at(ticket, col) end)
    |> Enum.all?(&valid_value?(&1, rule))
  end


  # Partial solution. Finished by hand.
  def p2 do
    rules = parse_rules()

    tickets =
      (parse_nearby_tickets() ++ parse_my_ticket()) |> Enum.filter(&valid_ticket?(&1, rules))

    tickets |> IO.inspect(limit: :infinity, width: 120)

    for rule <- rules,
        into: %{} do
      valid_columns =
        0..19
        |> Enum.filter(fn col -> valid_column?(col, tickets, rule) end)

      {rule["field"], valid_columns}
    end
    |> IO.inspect(limit: :infinity)
    :ok
  end
end
