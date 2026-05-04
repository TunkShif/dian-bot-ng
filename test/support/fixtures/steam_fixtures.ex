defmodule Dian.SteamFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dian.Steam` context.
  """

  alias Dian.Steam

  def unique_steam_id do
    "7656#{System.unique_integer([:positive]) |> Integer.to_string() |> String.pad_leading(13, "0")}"
  end

  def unique_qq_id do
    (10_000 + System.unique_integer([:positive])) |> Integer.to_string()
  end

  def valid_steam_player_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      steam_id: unique_steam_id(),
      qq_id: unique_qq_id()
    })
  end

  def steam_player_fixture(attrs \\ %{}) do
    {:ok, steam_player} =
      attrs
      |> valid_steam_player_attributes()
      |> Steam.bind_steam_player()

    steam_player
  end
end
