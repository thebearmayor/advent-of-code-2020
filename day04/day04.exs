input = File.read!("input")
passports = input |> String.trim |> String.split("\n\n")

defmodule Passport do
  def split_fields(passport) do
    passport |> String.split()
  end

  def split_field(field) do
    [name, value] = field |> String.split(":")
    {String.to_atom(name), value}
  end

  def parse_passport(passport) do
    passport |> split_fields |> Enum.map(fn f -> split_field(f) end) |> Enum.into(%{})
  end

  def valid?(passport) do
    size = passport |> parse_passport |> Map.drop([:cid]) |> map_size
    size == 7
  end

  def valid_byr?(byr) do
    year = String.to_integer(byr)
    1920 <= year and year <= 2002
  end

  def valid_iyr?(iyr) do
    year = String.to_integer(iyr)
    2010 <= year and year <= 2020
  end

  def valid_eyr?(eyr) do
    year = String.to_integer(eyr)
    2020 <= year and year <= 2030
  end

  def valid_hgt?(hgt) do
    unit = String.slice(hgt, -2..-1)
    case unit do
      "in" ->
        inches = String.slice(hgt, 0..-3) |> String.to_integer
        59 <= inches and inches <= 76
      "cm" ->
        cms = String.slice(hgt, 0..-3) |> String.to_integer
        150 <= cms and cms <= 193
      _ -> false
    end
  end

  def valid_hcl?(hcl) do
    try do
      String.length(hcl) == 7 and
        String.slice(hcl, 0..0) == "#" and
        String.slice(hcl, 1..-1) |> String.to_integer(16) >= 0
    rescue
      ArgumentError -> false
    end
  end

  def valid_ecl?(ecl) do
    colors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    Enum.any?(colors, & &1 == ecl)
  end

  def valid_pid?(pid) do
    String.length(pid) == 9 and
    case Integer.parse(pid) do
      {_, ""} -> true
      _ -> false
    end
  end

  def valid_2?(passport) do
    parsed = parse_passport(passport) |> Map.drop([:cid])
    map_size(parsed) == 7 and
      valid_byr?(parsed.byr) and
      valid_iyr?(parsed.iyr) and
      valid_eyr?(parsed.eyr) and
      valid_hgt?(parsed.hgt) and
      valid_hcl?(parsed.hcl) and
      valid_ecl?(parsed.ecl) and
      valid_pid?(parsed.pid)
  end
end

passports |> Enum.count(fn p -> Passport.valid?(p) end) |> IO.puts
passports |> Enum.count(fn p -> Passport.valid_2?(p) end) |> IO.puts
