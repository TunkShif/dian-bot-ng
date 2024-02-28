defmodule Dian.Sqids do
  import Sqids.Hacks, only: [dialyzed_ctx: 1]

  @secret Application.compile_env!(:dian, Dian.Sqids) |> Keyword.fetch!(:secret)
  @alphabet Application.compile_env!(:dian, Dian.Sqids) |> Keyword.fetch!(:alphabet)

  @context Sqids.new!(min_length: 5, alphabet: @alphabet)

  def encode(number) when is_integer(number) do
    Sqids.encode!(dialyzed_ctx(@context), [number, @secret])
  end

  def decode(id) do
    case Sqids.decode!(dialyzed_ctx(@context), id) do
      [number, @secret] -> {:ok, number}
      _ -> {:error, "Could not decode hashed ID from value #{inspect(id)}"}
    end
  end
end
