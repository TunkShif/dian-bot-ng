defmodule Dian.Storage.Adapter do
  @callback get_url(String.t()) :: String.t()
  @callback exists?(String.t()) :: boolean()
  @callback upload(String.t(), String.t()) :: {:ok, {String.t(), binary()}} | {:error, any()}
end
