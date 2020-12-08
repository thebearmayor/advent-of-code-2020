input = File.read!("input")
lines = String.split(input)
numbers = Enum.map(lines, fn x -> String.to_integer(x) end)

for x <- numbers,
    y <- numbers,
    x + y == 2020 do
  IO.puts(x * y)
end

for x <- numbers,
    y <- numbers,
    z <- numbers,
    x + y + z == 2020 do
  IO.puts(x * y * z)
end
