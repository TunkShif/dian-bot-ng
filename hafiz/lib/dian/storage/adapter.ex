defmodule Dian.Storage.Adapter do
  @callback get_url(String.t()) :: String.t()
  @callback exists?(String.t()) :: boolean()
  @callback upload(any()) :: {:ok, String.t()} | {:error, any()}
end
