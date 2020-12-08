input = File.read!("modified") |> String.trim |> String.split |> Enum.map(& String.to_integer(&1, 2))
Enum.filter(54..930, fn el -> !Enum.member?(input, el) end) |> IO.inspect
