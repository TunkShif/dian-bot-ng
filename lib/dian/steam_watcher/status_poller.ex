defmodule Dian.SteamWatcher.StatusPoller do
  use GenServer

  require Logger

  alias Dian.Steam
  alias Dian.Steam.PlayerSummary
  alias Dian.SteamWatcher.StatusChanged

  @pubsub Dian.PubSub
  @topic "steam:player_status"
  @interval :timer.minutes(10)

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

  def broadcast_status_changed(%StatusChanged{} = event) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, event)
  end

  @impl true
  def init(opts) do
    state = %{
      snapshots: %{},
      interval: Keyword.get(opts, :interval, @interval),
      list_bindings: Keyword.get(opts, :list_bindings, &Steam.list_steam_players/0),
      fetch_summaries: Keyword.get(opts, :fetch_summaries, &Steam.get_player_summaries/1),
      broadcast: Keyword.get(opts, :broadcast, &broadcast_status_changed/1),
      timer_ref: nil
    }

    Logger.info("steam watcher status poller started",
      event: "steam_watcher_status_poller_started",
      interval_ms: state.interval
    )

    {:ok, schedule_poll(state)}
  end

  @impl true
  def handle_call(:check_now, _from, state) do
    Logger.info("steam watcher manual status poll triggered",
      event: "steam_watcher_status_poll_manual_triggered"
    )

    case check_players(state) do
      {:ok, events, state} -> {:reply, {:ok, events}, state}
      {:error, reason, state} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info(:poll, state) do
    Logger.info("steam watcher scheduled status poll triggered",
      event: "steam_watcher_status_poll_triggered"
    )

    state =
      case check_players(state) do
        {:ok, _events, next_state} -> next_state
        {:error, _reason, next_state} -> next_state
      end

    {:noreply, schedule_poll(state)}
  end

  defp schedule_poll(%{interval: false} = state), do: state
  defp schedule_poll(%{interval: nil} = state), do: state

  defp schedule_poll(%{interval: interval} = state) when is_integer(interval) and interval > 0 do
    %{state | timer_ref: Process.send_after(self(), :poll, interval)}
  end

  defp check_players(state) do
    bindings = state.list_bindings.()
    steam_ids = Enum.map(bindings, & &1.steam_id)

    if steam_ids == [] do
      Logger.info("steam watcher status poll skipped with no bindings",
        event: "steam_watcher_status_poll_skipped_no_bindings"
      )

      {:ok, [], state}
    else
      Logger.info("steam watcher status poll started",
        event: "steam_watcher_status_poll_started",
        steam_ids_count: length(steam_ids)
      )

      fetch_and_compare(bindings, steam_ids, state)
    end
  end

  defp fetch_and_compare(bindings, steam_ids, state) do
    case state.fetch_summaries.(steam_ids) do
      {:ok, summaries} ->
        changed_at = DateTime.utc_now(:second)
        bindings_by_steam_id = Map.new(bindings, &{&1.steam_id, &1})
        summaries_by_steam_id = Map.new(summaries, &{&1.steam_id, &1})

        events =
          summaries
          |> Enum.flat_map(
            &status_changed_event(&1, state.snapshots, bindings_by_steam_id, changed_at)
          )

        Logger.info("steam watcher status poll finished",
          event: "steam_watcher_status_poll_finished",
          steam_ids_count: length(steam_ids),
          summaries_count: length(summaries),
          changed_count: length(events)
        )

        Enum.each(events, state.broadcast)

        {:ok, events, %{state | snapshots: Map.merge(state.snapshots, summaries_by_steam_id)}}

      {:error, reason} ->
        Logger.warning("steam watcher status poll failed",
          event: "steam_watcher_status_poll_failed",
          steam_ids_count: length(steam_ids),
          reason: inspect(reason)
        )

        {:error, reason, state}
    end
  end

  defp status_changed_event(
         %PlayerSummary{} = current,
         snapshots,
         bindings_by_steam_id,
         changed_at
       ) do
    previous = Map.get(snapshots, current.steam_id)
    binding = Map.get(bindings_by_steam_id, current.steam_id)

    if playing_changed?(previous, current) and binding do
      [
        %StatusChanged{
          steam_id: current.steam_id,
          qq_id: binding.qq_id,
          previous_game_id: previous.playing_game_id,
          previous_game_name: previous.playing_game_name,
          current_game_id: current.playing_game_id,
          current_game_name: current.playing_game_name,
          changed_at: changed_at
        }
      ]
    else
      []
    end
  end

  defp playing_changed?(nil, _current), do: false

  defp playing_changed?(%PlayerSummary{} = previous, %PlayerSummary{} = current) do
    current.playing_game_id not in [nil, ""] and
      previous.playing_game_id != current.playing_game_id
  end
end
