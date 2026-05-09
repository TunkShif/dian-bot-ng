defmodule Dian.AI.DailySteamSummaryScheduler do
  use GenServer

  require Logger

  alias Dian.AI

  @utc8_offset_seconds 8 * 60 * 60

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    genserver_opts = if name, do: [name: name], else: []
    GenServer.start_link(__MODULE__, opts, genserver_opts)
  end

  def next_run_at(%DateTime{} = now) do
    local_now = DateTime.add(now, @utc8_offset_seconds, :second)
    local_date = DateTime.to_date(local_now)
    local_time = DateTime.to_time(local_now)

    target_date =
      if Time.compare(local_time, ~T[10:00:00]) == :lt,
        do: local_date,
        else: Date.add(local_date, 1)

    {:ok, run_at} = DateTime.new(target_date, ~T[10:00:00], "Etc/UTC")
    DateTime.add(run_at, -@utc8_offset_seconds, :second)
  end

  @impl true
  def init(opts) do
    run_daily_group_summaries =
      Keyword.get(opts, :run_daily_group_summaries, &AI.run_daily_group_summaries/0)

    now = Keyword.get(opts, :now, &DateTime.utc_now/1)
    state = %{run_daily_group_summaries: run_daily_group_summaries, now: now, timer_ref: nil}

    Logger.info("ai daily steam summary scheduler started",
      event: "ai_daily_steam_summary_scheduler_started"
    )

    {:ok, schedule_next_run(state)}
  end

  @impl true
  def handle_info(:run, state) do
    _ = state.run_daily_group_summaries.()
    {:noreply, schedule_next_run(state)}
  end

  defp schedule_next_run(state) do
    now = state.now.(:second)
    run_at = next_run_at(now)
    delay = max(DateTime.diff(run_at, now, :millisecond), 0)

    Logger.info("ai daily steam summary scheduler next run scheduled",
      event: "ai_daily_steam_summary_scheduler_next_run_scheduled",
      delay_ms: delay
    )

    %{state | timer_ref: Process.send_after(self(), :run, delay)}
  end
end
