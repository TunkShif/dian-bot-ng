defmodule Dian.Steam do
  @moduledoc """
  The Steam context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Dian.Groups
  alias Dian.Repo
  alias Dian.Steam.Client
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

  @doc """
  Fetches one Steam player summary from the configured Steam client.
  """
  def get_player_summary(steam_id) when is_binary(steam_id) do
    Client.get_player_summary(steam_id)
  end

  @doc """
  Fetches Steam player summaries from the configured Steam client.
  """
  def get_player_summaries(steam_ids) when is_list(steam_ids) do
    Client.get_player_summaries(steam_ids)
  end

  @doc """
  Looks up a Steam binding by qq_id and fetches the player summary.

  Returns `{:ok, %PlayerSummary{}}` when a binding exists and the Steam API responds,
  `{:error, :not_bound}` when no binding exists for the given qq_id,
  or `{:error, :steam_api_error}` when the binding exists but the Steam API fails.
  """
  def get_bound_player_summary_by_qq_id(qq_id) when is_binary(qq_id) do
    case get_steam_player_by_qq_id(qq_id) do
      nil ->
        {:error, :not_bound}

      %SteamPlayer{steam_id: steam_id} ->
        case get_player_summaries([steam_id]) do
          {:ok, []} -> {:error, :not_found}
          {:ok, [summary]} -> {:ok, summary}
          {:error, _reason} -> {:error, :steam_api_error}
        end
    end
  end

  @doc """
  Upserts a Steam binding: one steam_id maps to one qq_id and vice-versa.

  Conflicting existing bindings (same steam_id or same qq_id pointing to a
  different counterpart) are deleted atomically before the new binding is
  inserted, all within a single `Ecto.Multi` transaction.

  Returns `{:ok, %SteamPlayer{}}` on success or `{:error, %Ecto.Changeset{}}` on failure.
  """
  def upsert_binding(qq_id, steam_id) when is_binary(qq_id) and is_binary(steam_id) do
    Multi.new()
    |> Multi.delete_all(:remove_by_qq_id, from(sp in SteamPlayer, where: sp.qq_id == ^qq_id))
    |> Multi.delete_all(
      :remove_by_steam_id,
      from(sp in SteamPlayer, where: sp.steam_id == ^steam_id)
    )
    |> Multi.insert(
      :insert,
      SteamPlayer.changeset(%SteamPlayer{}, %{qq_id: qq_id, steam_id: steam_id})
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{insert: steam_player}} -> {:ok, steam_player}
      {:error, :insert, changeset, _changes} -> {:error, changeset}
    end
  end

  @doc """
  Binds the authenticated user's own QQ ID to a Steam ID.

  Derives the qq_id from the current scope and delegates to `upsert_binding/2`.
  """
  def bind_self(%Dian.Accounts.Scope{qq_id: qq_id}, steam_id)
      when is_binary(qq_id) and is_binary(steam_id) do
    upsert_binding(qq_id, steam_id)
  end

  @doc """
  Binds a group member's QQ ID to a Steam ID after verifying the caller
  is a group admin for the given group.

  Delegates authorization to `Dian.Groups.authorize_group_admin/2` and
  the write to `upsert_binding/2`.
  """
  def bind_member(scope, group_id, qq_id, steam_id)
      when is_binary(group_id) and is_binary(qq_id) and is_binary(steam_id) do
    with :ok <- Groups.authorize_group_admin(scope, group_id),
         :ok <- verify_group_member(group_id, qq_id) do
      upsert_binding(qq_id, steam_id)
    end
  end

  defp verify_group_member(group_id, qq_id) do
    case DianBot.get_group_member_info(group_id, qq_id) do
      {:ok, _member} -> :ok
      {:error, _reason} -> {:error, :not_found}
    end
  end
end
