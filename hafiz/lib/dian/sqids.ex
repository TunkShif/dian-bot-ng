defmodule Dian.Sqids do
  import Sqids.Hacks, only: [dialyzed_ctx: 1]

  @secret Application.compile_env!(:dian, Dian.Sqids) |> Keyword.fetch!(:secret)
  @alphabet Application.compile_env!(:dian, Dian.Sqids) |> Keyword.fetch!(:alphabet)

  @context Sqids.new!(min_length: 7, alphabet: @alphabet)

  def encode!(numbers), do: Sqids.encode!(dialyzed_ctx(@context), numbers ++ [@secret])
  def decode!(id), do: Sqids.decode!(dialyzed_ctx(@context), id)
end
