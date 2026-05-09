defmodule Dian.SteamWatcher.PlaySessionTracker do
  @moduledoc """
  Tracks inferred Steam play sessions between status polls.
  """

  alias Dian.Steam.PlayerSummary

  def new, do: %{}

  def track(open_sessions, nil, %PlayerSummary{} = current, binding, changed_at) do
    if playing?(current) and binding do
      {put_open_session(open_sessions, current, binding, changed_at), []}
    else
      {open_sessions, []}
    end
  end

  def track(
        open_sessions,
        %PlayerSummary{} = _previous,
        %PlayerSummary{} = _current,
        nil,
        _changed_at
      ) do
    {open_sessions, []}
  end

  def track(
        open_sessions,
        %PlayerSummary{} = previous,
        %PlayerSummary{} = current,
        binding,
        changed_at
      ) do
    cond do
      not playing?(previous) and playing?(current) ->
        {put_open_session(open_sessions, current, binding, changed_at), []}

      playing?(previous) and same_game?(previous, current) ->
        {touch_open_session(open_sessions, current.steam_id, changed_at), []}

      playing?(previous) and playing?(current) ->
        finalized =
          open_sessions
          |> Map.get(current.steam_id)
          |> finalize_open_session(changed_at, :switched)

        next_sessions =
          put_open_session(
            Map.delete(open_sessions, current.steam_id),
            current,
            binding,
            changed_at
          )

        {next_sessions, wrap_session(finalized)}

      playing?(previous) ->
        finalized =
          open_sessions
          |> Map.get(current.steam_id)
          |> finalize_open_session(changed_at, :stopped)

        {Map.delete(open_sessions, current.steam_id), wrap_session(finalized)}

      true ->
        {open_sessions, []}
    end
  end

  defp put_open_session(open_sessions, current, binding, changed_at) do
    Map.put(open_sessions, current.steam_id, %{
      qq_id: binding.qq_id,
      steam_id: current.steam_id,
      app_id: current.playing_game_id,
      game_name: current.playing_game_name,
      player_display_name: binding.display_name || current.name,
      started_at: changed_at,
      last_seen_at: changed_at
    })
  end

  defp touch_open_session(open_sessions, steam_id, changed_at) do
    case Map.get(open_sessions, steam_id) do
      nil -> open_sessions
      session -> Map.put(open_sessions, steam_id, %{session | last_seen_at: changed_at})
    end
  end

  defp finalize_open_session(nil, _changed_at, _end_reason), do: nil

  defp finalize_open_session(session, changed_at, end_reason) do
    started_at = session.started_at
    duration_seconds = DateTime.diff(changed_at, started_at, :second)

    session
    |> Map.take([:qq_id, :steam_id, :app_id, :game_name, :player_display_name, :started_at])
    |> Map.merge(%{
      ended_at: changed_at,
      duration_seconds: max(duration_seconds, 0),
      session_end_reason: end_reason
    })
  end

  defp wrap_session(nil), do: []
  defp wrap_session(session), do: [session]

  defp playing?(%PlayerSummary{playing_game_id: playing_game_id}),
    do: playing_game_id not in [nil, ""]

  defp same_game?(%PlayerSummary{} = previous, %PlayerSummary{} = current),
    do: previous.playing_game_id == current.playing_game_id
end
