defmodule DianBot.Client.Test do
  use Agent

  # TODO: replace this with Hammox
  @behaviour DianBot.Client

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def stub(action, fun) when is_binary(action) and is_function(fun, 2) do
    Agent.update(__MODULE__, &Map.put(&1, action, fun))
  end

  @impl true
  def request(action, params, opts) do
    __MODULE__
    |> Agent.get(&Map.get(&1, action))
    |> case do
      nil -> {:error, {:not_stubbed, action}}
      fun -> fun.(params, opts)
    end
  end
end
