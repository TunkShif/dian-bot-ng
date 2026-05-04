defmodule Dian.Steam do
  @moduledoc """
  The Steam context.
  """

  import Ecto.Query, warn: false

  alias Dian.Repo
  alias Dian.Steam.SteamPlayer

  @doc """
  Returns the list of all steam player bindings.
  """
  def list_steam_players do
    Repo.all(SteamPlayer)
  end

  @doc """
  Gets a steam player binding by steam_id.

  Returns `nil` if no binding exists.
  """
  def get_steam_player_by_steam_id(steam_id) when is_binary(steam_id) do
    Repo.get_by(SteamPlayer, steam_id: steam_id)
  end

  @doc """
  Gets a steam player binding by qq_id.

  Returns `nil` if no binding exists.
  """
  def get_steam_player_by_qq_id(qq_id) when is_binary(qq_id) do
    Repo.get_by(SteamPlayer, qq_id: qq_id)
  end

  @doc """
  Binds a Steam ID to a QQ ID.

  Returns `{:ok, %SteamPlayer{}}` on success or `{:error, %Ecto.Changeset{}}` on failure.
  """
  def bind_steam_player(attrs) do
    %SteamPlayer{}
    |> SteamPlayer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Unbinds (deletes) a steam player binding by steam_id.

  Returns `:ok` on success or `{:error, :not_found}` if the binding does not exist.
  """
  def unbind_steam_player(steam_id) when is_binary(steam_id) do
    case get_steam_player_by_steam_id(steam_id) do
      nil -> {:error, :not_found}
      steam_player -> Repo.delete(steam_player) |> then(fn {:ok, _} -> :ok end)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking steam player changes.
  """
  def change_steam_player(%SteamPlayer{} = steam_player, attrs \\ %{}) do
    SteamPlayer.changeset(steam_player, attrs)
  end
end
