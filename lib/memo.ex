defmodule Memo do
  use Agent

  def start_link() do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn state -> Map.get(state, key) end)
  end

  def update(key, value) do
    Agent.update(__MODULE__, fn state -> Map.put(state, key, value) end)
  end

  def reset do
    Agent.update(__MODULE__, fn _ -> Map.new end)
  end
end
