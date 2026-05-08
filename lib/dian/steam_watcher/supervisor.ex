defmodule Dian.SteamWatcher.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      Dian.SteamWatcher.StatusPoller,
      {Dian.SteamWatcher.StatusNotifier, subscribe?: subscribe_watchers?()},
      Dian.SteamWatcher.AchievementPoller,
      {Dian.SteamWatcher.AchievementNotifier, subscribe?: subscribe_watchers?()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp subscribe_watchers? do
    Application.get_env(:dian, :steam_watcher_subscriptions?, true)
  end
end
