defmodule Dian.SteamWatcher.AchievementPoller do
  use GenServer

  require Logger

  alias Dian.Steam
  alias Dian.Steam.AchievementSnapshot
  alias Dian.Steam.GameSchema
  alias Dian.Steam.PlayerAchievement
  alias Dian.Steam.PlayerSummary
  alias Dian.SteamWatcher.AchievementUnlocked

  @pubsub Dian.PubSub
  @topic "steam:player_achievements"
  @interval :timer.minutes(5)

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    genserver_opts = if name, do: [name: name], else: []

    GenServer.start_link(__MODULE__, opts, genserver_opts)
  end

  def check_now(server \\ __MODULE__) do
    GenServer.call(server, :check_now, :infinity)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def broadcast_achievement_unlocked(%AchievementUnlocked{} = event) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, event)
  end

  @impl true
  def init(opts) do
    state = %{
      snapshots:
        load_snapshots(Keyword.get(opts, :list_snapshots, &Steam.list_achievement_snapshots/0)),
      interval: Keyword.get(opts, :interval, @interval),
      locale: Keyword.get(opts, :locale, notification_locale()),
      list_bindings: Keyword.get(opts, :list_bindings, &Steam.list_steam_players/0),
      fetch_summaries: Keyword.get(opts, :fetch_summaries, &Steam.get_player_summaries/1),
      fetch_achievements:
        Keyword.get(opts, :fetch_achievements, &Steam.get_player_achievements/3),
      get_game_schema: Keyword.get(opts, :get_game_schema, &GameSchema.fetch/2),
      save_snapshot: Keyword.get(opts, :save_snapshot, &Steam.upsert_achievement_snapshot/1),
      delete_snapshot: Keyword.get(opts, :delete_snapshot, &Steam.delete_achievement_snapshot/2),
      broadcast: Keyword.get(opts, :broadcast, &broadcast_achievement_unlocked/1),
      timer_ref: nil
    }

    Logger.info("steam watcher achievement poller started",
      event: "steam_watcher_achievement_poller_started",
      interval_ms: state.interval
    )

    {:ok, schedule_poll(state)}
  end

  @impl true
  def handle_call(:check_now, _from, state) do
    case poll(state) do
      {:ok, events, next_state} -> {:reply, {:ok, events}, next_state}
      {:error, reason, next_state} -> {:reply, {:error, reason}, next_state}
    end
  end

  @impl true
  def handle_info(:poll, state) do
    next_state =
      case poll(state) do
        {:ok, _events, next_state} -> next_state
        {:error, _reason, next_state} -> next_state
      end

    {:noreply, schedule_poll(next_state)}
  end

  defp schedule_poll(%{interval: false} = state), do: state
  defp schedule_poll(%{interval: nil} = state), do: state

  defp schedule_poll(%{interval: interval} = state) when is_integer(interval) and interval > 0 do
    %{state | timer_ref: Process.send_after(self(), :poll, interval)}
  end

  defp poll(state) do
    bindings = state.list_bindings.()
    steam_ids = Enum.map(bindings, & &1.steam_id)

    if steam_ids == [] do
      {:ok, [], state}
    else
      bindings_by_steam_id = Map.new(bindings, &{&1.steam_id, &1})

      case state.fetch_summaries.(steam_ids) do
        {:ok, summaries} ->
          process_summaries(summaries, bindings_by_steam_id, state)

        {:error, reason} ->
          Logger.warning("steam watcher achievement poll failed",
            event: "steam_watcher_achievement_poll_failed",
            reason: inspect(reason)
          )

          {:error, reason, state}
      end
    end
  end

  defp process_summaries(summaries, bindings_by_steam_id, state) do
    active_sessions =
      summaries
      |> Enum.filter(&playing?/1)
      |> Map.new(fn %PlayerSummary{} = summary ->
        {session_key(summary.steam_id, summary.playing_game_id), summary}
      end)

    changed_at = DateTime.utc_now(:second)

    {events, snapshots} =
      Enum.reduce(active_sessions, {[], state.snapshots}, fn
        {{steam_id, _app_id} = key, %PlayerSummary{} = summary}, {events, snapshots} ->
          binding = Map.get(bindings_by_steam_id, steam_id)
          previous = Map.get(snapshots, key)

          case maybe_poll_session(previous, binding, summary, changed_at, state) do
            {:ok, [], snapshot} ->
              {events, put_snapshot(snapshots, key, snapshot)}

            {:ok, session_events, snapshot} ->
              {events ++ session_events, put_snapshot(snapshots, key, snapshot)}

            {:skip, snapshot} ->
              {events, put_snapshot(snapshots, key, snapshot)}

            {:error, _reason} ->
              {events, snapshots}
          end
      end)

    inactive_keys = Map.keys(state.snapshots) -- Map.keys(active_sessions)

    {events, snapshots} =
      Enum.reduce(inactive_keys, {events, snapshots}, fn key, {events, snapshots} ->
        snapshot = Map.fetch!(snapshots, key)

        case finalize_session(snapshot, changed_at, state) do
          {:ok, final_events} ->
            {events ++ final_events, Map.delete(snapshots, key)}

          {:error, _reason} ->
            {events, snapshots}
        end
      end)

    Enum.each(events, state.broadcast)
    {:ok, events, %{state | snapshots: snapshots}}
  end

  defp maybe_poll_session(nil, binding, summary, changed_at, state) do
    with {:ok, achievements} <-
           state.fetch_achievements.(summary.steam_id, summary.playing_game_id, state.locale),
         snapshot <- build_snapshot(binding, summary, achievements, changed_at) do
      persist_snapshot(snapshot, state)
      {:ok, [], snapshot}
    else
      {:error, :no_stats} ->
        snapshot =
          build_snapshot(binding, summary, [], changed_at, %{completion_state: :no_stats})

        persist_snapshot(snapshot, state)
        {:skip, snapshot}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_poll_session(
         %AchievementSnapshot{completion_state: completion_state} = snapshot,
         _binding,
         %PlayerSummary{} = summary,
         changed_at,
         state
       )
       when completion_state in [:no_stats, :fully_unlocked] do
    snapshot =
      snapshot
      |> snapshot_attrs_from(summary, changed_at)
      |> Map.put(:completion_state, completion_state)

    persist_snapshot(snapshot, state)
    {:skip, snapshot}
  end

  defp maybe_poll_session(
         %AchievementSnapshot{} = previous,
         binding,
         %PlayerSummary{} = summary,
         changed_at,
         state
       ) do
    with {:ok, achievements} <-
           state.fetch_achievements.(summary.steam_id, summary.playing_game_id, state.locale) do
      current = build_snapshot(binding, summary, achievements, changed_at)
      event = diff_event(previous, current, changed_at, state)
      snapshot = maybe_complete_snapshot(current, achievements)

      persist_snapshot(snapshot, state)

      case event do
        nil -> {:ok, [], snapshot}
        %AchievementUnlocked{} = event -> {:ok, [event], snapshot}
      end
    else
      {:error, :no_stats} ->
        snapshot =
          previous
          |> snapshot_attrs_from(summary, changed_at)
          |> Map.put(:completion_state, :no_stats)

        persist_snapshot(snapshot, state)
        {:skip, snapshot}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp finalize_session(
         %AchievementSnapshot{
           completion_state: completion_state,
           steam_id: steam_id,
           app_id: app_id
         },
         _changed_at,
         state
       )
       when completion_state in [:no_stats, :fully_unlocked] do
    state.delete_snapshot.(steam_id, app_id)
    {:ok, []}
  end

  defp finalize_session(%AchievementSnapshot{} = snapshot, changed_at, state) do
    with {:ok, achievements} <-
           state.fetch_achievements.(snapshot.steam_id, snapshot.app_id, state.locale) do
      current =
        struct!(AchievementSnapshot, %{
          Map.from_struct(snapshot)
          | unlocked_achievements: unlocked_map(achievements),
            last_checked_at: changed_at,
            completion_state: completion_state(achievements)
        })

      event = diff_event(snapshot, current, changed_at, state)

      state.delete_snapshot.(snapshot.steam_id, snapshot.app_id)

      case event do
        nil -> {:ok, []}
        %AchievementUnlocked{} = event -> {:ok, [event]}
      end
    else
      {:error, :no_stats} ->
        state.delete_snapshot.(snapshot.steam_id, snapshot.app_id)
        {:ok, []}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp diff_event(previous, current, changed_at, state) do
    previous_unlocks = previous.unlocked_achievements || %{}

    new_unlocks =
      current.unlocked_achievements
      |> Enum.reject(fn {api_name, _attrs} -> Map.has_key?(previous_unlocks, api_name) end)
      |> Enum.sort_by(fn {_api_name, attrs} -> Map.get(attrs, "unlocktime", 0) end)

    if new_unlocks == [] do
      nil
    else
      schema =
        case state.get_game_schema.(current.app_id, state.locale) do
          {:ok, %GameSchema{} = schema} -> schema
          _ -> nil
        end

      %AchievementUnlocked{
        steam_id: current.steam_id,
        qq_id: current.qq_id,
        app_id: current.app_id,
        game_name: current.game_name,
        changed_at: changed_at,
        achievements: Enum.map(new_unlocks, &build_event_item(&1, schema))
      }
    end
  end

  defp build_event_item({api_name, attrs}, schema) do
    schema_achievement = if schema, do: Map.get(schema.achievements, api_name)
    schema_display_name = if schema_achievement, do: schema_achievement.display_name
    schema_description = if schema_achievement, do: schema_achievement.description
    schema_icon_url = if schema_achievement, do: schema_achievement.icon_url
    schema_hidden = if schema_achievement, do: schema_achievement.hidden

    %AchievementUnlocked.Item{
      api_name: api_name,
      display_name: Map.get(attrs, "display_name") || schema_display_name,
      description: Map.get(attrs, "description") || schema_description,
      icon_url: schema_icon_url,
      unlocktime: Map.get(attrs, "unlocktime"),
      hidden: schema_hidden
    }
  end

  defp build_snapshot(binding, summary, achievements, checked_at, extra_attrs \\ %{}) do
    attrs =
      %{
        steam_id: summary.steam_id,
        qq_id: binding.qq_id,
        app_id: summary.playing_game_id,
        game_name: summary.playing_game_name,
        unlocked_achievements: unlocked_map(achievements),
        completion_state: completion_state(achievements),
        last_checked_at: checked_at
      }
      |> Map.merge(extra_attrs)

    struct!(AchievementSnapshot, attrs)
  end

  defp snapshot_attrs_from(%AchievementSnapshot{} = snapshot, summary, changed_at) do
    struct!(AchievementSnapshot, %{
      Map.from_struct(snapshot)
      | game_name: summary.playing_game_name,
        last_checked_at: changed_at
    })
  end

  defp maybe_complete_snapshot(%AchievementSnapshot{} = snapshot, achievements) do
    %{snapshot | completion_state: completion_state(achievements)}
  end

  defp completion_state(achievements) when is_list(achievements) do
    if achievements != [] and Enum.all?(achievements, & &1.achieved?) do
      :fully_unlocked
    else
      :active
    end
  end

  defp unlocked_map(achievements) do
    achievements
    |> Enum.filter(& &1.achieved?)
    |> Map.new(fn %PlayerAchievement{} = achievement ->
      {achievement.api_name,
       %{
         "unlocktime" => achievement.unlocktime,
         "display_name" => achievement.display_name,
         "description" => achievement.description
       }}
    end)
  end

  defp load_snapshots(list_snapshots) do
    list_snapshots.()
    |> Map.new(fn %AchievementSnapshot{} = snapshot ->
      {session_key(snapshot.steam_id, snapshot.app_id), snapshot}
    end)
  end

  defp persist_snapshot(%AchievementSnapshot{} = snapshot, state) do
    snapshot
    |> Map.from_struct()
    |> Map.drop([:__meta__, :id, :inserted_at, :updated_at])
    |> state.save_snapshot.()
  end

  defp put_snapshot(snapshots, key, %AchievementSnapshot{} = snapshot) do
    Map.put(snapshots, key, snapshot)
  end

  defp session_key(steam_id, app_id), do: {steam_id, app_id}

  defp playing?(%PlayerSummary{playing_game_id: game_id}), do: game_id not in [nil, ""]

  defp notification_locale do
    Application.get_env(:dian, :notification_locale, :zh)
  end
end
