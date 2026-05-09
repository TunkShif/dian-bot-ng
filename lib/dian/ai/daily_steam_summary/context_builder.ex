defmodule Dian.AI.DailySteamSummary.ContextBuilder do
  @moduledoc """
  Builds the compact group context sent to the LLM layer.
  """

  def build(group, members, sessions, target_date) do
    members = Enum.map(members, &compact_member/1)

    player_stats =
      sessions
      |> Enum.group_by(& &1.qq_id)
      |> Enum.map(fn {qq_id, player_sessions} ->
        games = Enum.map(player_sessions, & &1.game_name) |> Enum.reject(&is_nil/1)
        total_playtime = Enum.reduce(player_sessions, 0, &(&1.duration_seconds + &2))
        longest_session = Enum.max_by(player_sessions, & &1.duration_seconds)

        %{
          qq_id: qq_id,
          display_name: member_display_name(members, qq_id),
          total_playtime_seconds: total_playtime,
          session_count: length(player_sessions),
          games_played: Enum.uniq(games),
          top_game: top_game(player_sessions),
          longest_session_seconds: longest_session.duration_seconds,
          first_game:
            player_sessions |> Enum.min_by(& &1.started_at, DateTime) |> Map.get(:game_name),
          last_game:
            player_sessions |> Enum.max_by(& &1.ended_at, DateTime) |> Map.get(:game_name)
        }
      end)
      |> Enum.sort_by(&{&1.display_name || "", &1.qq_id})

    %{
      group_id: group.group_id,
      group_name: Map.get(group, :group_name),
      target_date: target_date,
      members: members,
      sessions: Enum.sort_by(sessions, &{&1.qq_id, &1.started_at}),
      player_stats: player_stats,
      group_stats: %{
        total_playtime_seconds: Enum.reduce(sessions, 0, &(&1.duration_seconds + &2)),
        most_played_game: top_game(sessions),
        longest_playtime_player: longest_playtime_player(player_stats),
        most_switches_player: most_switches_player(player_stats)
      }
    }
  end

  defp compact_member(member) do
    %{
      user_id: to_string(member.user_id),
      display_name: Map.get(member, :display_name),
      nickname: Map.get(member, :nickname)
    }
  end

  defp member_display_name(members, qq_id) do
    members
    |> Enum.find(&(&1.user_id == qq_id))
    |> case do
      nil -> qq_id
      member -> normalize_label(member.display_name) || normalize_label(member.nickname) || qq_id
    end
  end

  defp normalize_label(value) when is_binary(value) do
    value = String.trim(value)
    if value == "", do: nil, else: value
  end

  defp normalize_label(_), do: nil

  defp top_game([]), do: nil

  defp top_game(sessions) do
    sessions
    |> Enum.group_by(& &1.game_name)
    |> Enum.max_by(fn {_game, grouped_sessions} ->
      Enum.reduce(grouped_sessions, 0, &(&1.duration_seconds + &2))
    end)
    |> elem(0)
  end

  defp longest_playtime_player([]), do: nil

  defp longest_playtime_player(player_stats),
    do: Enum.max_by(player_stats, & &1.total_playtime_seconds).display_name

  defp most_switches_player([]), do: nil

  defp most_switches_player(player_stats),
    do: Enum.max_by(player_stats, & &1.session_count).display_name
end
