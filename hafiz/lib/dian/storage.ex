defmodule Dian.Storage do
  @behaviour Dian.Storage.Adapter

  @adapter Application.compile_env!(:dian, Dian.Storage) |> Keyword.fetch!(:adapter)

  defdelegate get_url(name), to: @adapter
  defdelegate exists?(name), to: @adapter
  defdelegate upload(params), to: @adapter
end
