defmodule Dian.Steam do
  @moduledoc """
  The Steam context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Dian.Groups
  alias Dian.Repo
  alias Dian.Steam.AchievementSnapshot
  alias Dian.Steam.Client
  alias Dian.Steam.PlaySession
  alias Dian.Steam.SteamPlayer

  @doc """
  Returns the list of all steam player bindings.
  """
  def list_steam_players do
    Repo.all(SteamPlayer)
  end

  @doc """
  Returns all persisted achievement snapshots.
  """
  def list_achievement_snapshots do
    Repo.all(AchievementSnapshot)
  end

  @doc """
  Gets a persisted achievement snapshot by steam_id and app_id.
  """
  def get_achievement_snapshot(steam_id, app_id)
      when is_binary(steam_id) and is_binary(app_id) do
    Repo.get_by(AchievementSnapshot, steam_id: steam_id, app_id: app_id)
  end

  @doc """
  Creates or updates an achievement snapshot keyed by steam_id and app_id.

  Uses an atomic `INSERT ... ON CONFLICT` to avoid race conditions when
  called concurrently. Returns `{:ok, %AchievementSnapshot{}}` on success
  or `{:error, %Ecto.Changeset{}}` on failure.
  """
  def upsert_achievement_snapshot(attrs) when is_map(attrs) do
    %AchievementSnapshot{}
    |> AchievementSnapshot.changeset(attrs)
    |> Repo.insert(
      on_conflict:
        {:replace,
         [
           :qq_id,
           :game_name,
           :unlocked_achievements,
           :completion_state,
           :last_checked_at,
           :updated_at
         ]},
      conflict_target: [:steam_id, :app_id]
    )
  end

  @doc """
  Deletes a persisted achievement snapshot by steam_id and app_id.
  """
  def delete_achievement_snapshot(steam_id, app_id)
      when is_binary(steam_id) and is_binary(app_id) do
    case get_achievement_snapshot(steam_id, app_id) do
      nil ->
        :ok

      snapshot ->
        case Repo.delete(snapshot) do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @doc """
  Persists a finalized Steam play session.
  """
  def create_play_session(attrs) when is_map(attrs) do
    %PlaySession{}
    |> PlaySession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns play sessions for one player that overlap the given date range.
  """
  def list_play_sessions_for_player(qq_id, %Date.Range{} = date_range) when is_binary(qq_id) do
    list_play_sessions_for_players([qq_id], date_range)
  end

  @doc """
  Returns play sessions for the given players that overlap the given date range.
  """
  def list_play_sessions_for_players(qq_ids, %Date.Range{} = date_range) when is_list(qq_ids) do
    {range_start, range_end} = date_range_bounds(date_range)

    PlaySession
    |> where([ps], ps.qq_id in ^qq_ids)
    |> where([ps], ps.started_at < ^range_end and ps.ended_at >= ^range_start)
    |> order_by([ps], asc: ps.started_at, asc: ps.id)
    |> Repo.all()
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
  Returns Steam player bindings for the given QQ IDs keyed by qq_id.
  """
  def get_steam_players_by_qq_ids(qq_ids) when is_list(qq_ids) do
    SteamPlayer
    |> where([sp], sp.qq_id in ^qq_ids)
    |> Repo.all()
    |> Map.new(&{&1.qq_id, &1})
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
  Fetches Steam player achievements for one player and app from the configured Steam client.
  """
  def get_player_achievements(steam_id, app_id, locale \\ :en)
      when is_binary(steam_id) and is_binary(app_id) and is_atom(locale) do
    Client.get_player_achievements(steam_id, app_id, locale)
  end

  @doc """
  Fetches Steam game achievement schema from the configured Steam client.
  """
  def get_game_schema(app_id, locale \\ :en) when is_binary(app_id) and is_atom(locale) do
    Client.get_game_schema(app_id, locale)
  end

  @doc """
  Looks up a Steam binding by qq_id and fetches the player summary.

  Returns `{:ok, %PlayerSummary{}}` when a binding exists and the Steam API responds,
  `{:ok, nil}` when no binding exists for the given qq_id,
  or `{:error, :steam_api_error}` when the binding exists but the Steam API fails.
  """
  def get_bound_player_summary_by_qq_id(qq_id) when is_binary(qq_id) do
    case get_steam_player_by_qq_id(qq_id) do
      nil ->
        {:ok, nil}

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
  def upsert_binding(qq_id, steam_id, display_name \\ nil)

  def upsert_binding(qq_id, steam_id, display_name)
      when is_binary(qq_id) and is_binary(steam_id) do
    Multi.new()
    |> Multi.delete_all(:remove_by_qq_id, from(sp in SteamPlayer, where: sp.qq_id == ^qq_id))
    |> Multi.delete_all(
      :remove_by_steam_id,
      from(sp in SteamPlayer, where: sp.steam_id == ^steam_id)
    )
    |> Multi.insert(
      :insert,
      SteamPlayer.changeset(%SteamPlayer{}, %{
        qq_id: qq_id,
        steam_id: steam_id,
        display_name: display_name
      })
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
  def bind_self(scope, steam_id, display_name \\ nil)

  def bind_self(%Dian.Accounts.Scope{qq_id: qq_id}, steam_id, display_name)
      when is_binary(qq_id) and is_binary(steam_id) do
    upsert_binding(qq_id, steam_id, display_name)
  end

  @doc """
  Binds a group member's QQ ID to a Steam ID after verifying the caller
  is a group admin for the given group.

  Delegates authorization to `Dian.Groups.authorize_group_admin/2` and
  the write to `upsert_binding/2`.
  """
  def bind_member(scope, group_id, qq_id, steam_id, display_name \\ nil)

  def bind_member(scope, group_id, qq_id, steam_id, display_name)
      when is_binary(group_id) and is_binary(qq_id) and is_binary(steam_id) do
    with :ok <- Groups.authorize_group_admin(scope, group_id),
         :ok <- verify_group_member(group_id, qq_id) do
      upsert_binding(qq_id, steam_id, display_name)
    end
  end

  defp verify_group_member(group_id, qq_id) do
    case DianBot.get_group_member_info(group_id, qq_id) do
      {:ok, _member} -> :ok
      {:error, :not_found} -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  defp date_range_bounds(%Date.Range{first: first, last: last}) do
    range_start = DateTime.new!(first, ~T[00:00:00], "Etc/UTC")
    range_end = last |> Date.add(1) |> DateTime.new!(~T[00:00:00], "Etc/UTC")
    {range_start, range_end}
  end
end
