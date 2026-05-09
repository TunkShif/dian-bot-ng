defmodule Dian.AI.DailySteamSummary.Runner do
  @moduledoc """
  Orchestrates daily Steam summary generation and delivery for enabled groups.
  """

  require Logger

  alias Dian.AI.DailySteamSummary
  alias Dian.AI.DailySteamSummary.ContextBuilder
  alias Dian.Settings
  alias Dian.Steam

  @utc8_offset_seconds 8 * 60 * 60

  def run(opts \\ []) do
    now = Keyword.get(opts, :now, DateTime.utc_now(:second))
    {target_date, range_start, range_end} = previous_local_day_bounds(now)

    list_enabled_group_ids =
      Keyword.get(opts, :list_enabled_group_ids, &Settings.list_enabled_group_ids/0)

    get_group_info = Keyword.get(opts, :get_group_info, &DianBot.get_group_info/1)

    get_group_member_list =
      Keyword.get(opts, :get_group_member_list, &DianBot.get_group_member_list/1)

    get_steam_players_by_qq_ids =
      Keyword.get(opts, :get_steam_players_by_qq_ids, &Steam.get_steam_players_by_qq_ids/1)

    list_sessions_for_players =
      Keyword.get(
        opts,
        :list_sessions_for_players,
        &Steam.list_play_sessions_for_players_between/3
      )

    generate_daily_group_summary =
      Keyword.get(opts, :generate_daily_group_summary, &DailySteamSummary.generate/1)

    send_group_message =
      Keyword.get(opts, :send_group_message, fn group_id, message ->
        DianBot.send_msg(:group, group_id, message)
      end)

    counts =
      list_enabled_group_ids.()
      |> Enum.reduce(
        %{processed_group_count: 0, sent_group_count: 0, skipped_group_count: 0},
        fn group_id, counts ->
          counts = %{counts | processed_group_count: counts.processed_group_count + 1}

          case process_group(
                 group_id,
                 target_date,
                 range_start,
                 range_end,
                 get_group_info,
                 get_group_member_list,
                 get_steam_players_by_qq_ids,
                 list_sessions_for_players,
                 generate_daily_group_summary,
                 send_group_message
               ) do
            :sent -> %{counts | sent_group_count: counts.sent_group_count + 1}
            :skipped -> %{counts | skipped_group_count: counts.skipped_group_count + 1}
          end
        end
      )

    {:ok, counts}
  end

  defp process_group(
         group_id,
         target_date,
         range_start,
         range_end,
         get_group_info,
         get_group_member_list,
         get_steam_players_by_qq_ids,
         list_sessions_for_players,
         generate_daily_group_summary,
         send_group_message
       ) do
    with {:ok, group} <- get_group_info.(group_id),
         {:ok, members} <- get_group_member_list.(group_id),
         qq_ids <- Enum.map(members, &to_string(&1.user_id)),
         steam_players_by_qq_id <- get_steam_players_by_qq_ids.(qq_ids),
         bound_qq_ids <- Map.keys(steam_players_by_qq_id),
         :ok <- ensure_present(bound_qq_ids, :no_bound_steam_players),
         sessions <- list_sessions_for_players.(bound_qq_ids, range_start, range_end),
         :ok <- ensure_present(sessions, :no_sessions_in_window),
         context <- ContextBuilder.build(group, members, sessions, target_date),
         {:ok, summary} <- generate_daily_group_summary.(context),
         {:ok, _message_id} <- send_group_message.(group_id, summary) do
      :sent
    else
      {:skip, reason} ->
        Logger.warning("ai daily steam summary group skipped: #{inspect(reason)}",
          event: "ai_daily_steam_summary_group_skipped",
          group_id: group_id,
          reason: inspect(reason)
        )

        :skipped

      {:error, reason} ->
        Logger.warning("ai daily steam summary group failed",
          event: "ai_daily_steam_summary_group_failed",
          group_id: group_id,
          reason: inspect(reason)
        )

        :skipped
    end
  end

  defp ensure_present([], reason), do: {:skip, reason}
  defp ensure_present(_values, _reason), do: :ok

  defp previous_local_day_bounds(now) do
    local_date =
      now
      |> DateTime.add(@utc8_offset_seconds, :second)
      |> DateTime.to_date()

    target_date = Date.add(local_date, -1)

    {:ok, start_at} = DateTime.new(target_date, ~T[00:00:00], "Etc/UTC")
    {:ok, end_at} = DateTime.new(Date.add(target_date, 1), ~T[00:00:00], "Etc/UTC")

    {target_date, DateTime.add(start_at, -@utc8_offset_seconds, :second),
     DateTime.add(end_at, -@utc8_offset_seconds, :second)}
  end
end
