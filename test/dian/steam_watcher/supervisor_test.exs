defmodule Dian.SteamWatcher.SupervisorTest do
  use ExUnit.Case, async: false

  alias Dian.SteamWatcher

  describe "start_link/1" do
    test "starts the watcher status and achievement pipelines" do
      supervisor = Process.whereis(SteamWatcher.Supervisor)

      children = Supervisor.which_children(supervisor)

      assert {SteamWatcher.StatusPoller, status_poller, :worker, [SteamWatcher.StatusPoller]} =
               List.keyfind(children, SteamWatcher.StatusPoller, 0)

      assert {SteamWatcher.StatusNotifier, status_notifier, :worker,
              [SteamWatcher.StatusNotifier]} =
               List.keyfind(children, SteamWatcher.StatusNotifier, 0)

      assert {SteamWatcher.AchievementPoller, achievement_poller, :worker,
              [SteamWatcher.AchievementPoller]} =
               List.keyfind(children, SteamWatcher.AchievementPoller, 0)

      assert {SteamWatcher.AchievementNotifier, achievement_notifier, :worker,
              [SteamWatcher.AchievementNotifier]} =
               List.keyfind(children, SteamWatcher.AchievementNotifier, 0)

      assert is_pid(status_poller)
      assert is_pid(status_notifier)
      assert is_pid(achievement_poller)
      assert is_pid(achievement_notifier)

      :sys.get_state(status_poller)
      :sys.get_state(status_notifier)
      :sys.get_state(achievement_poller)
      :sys.get_state(achievement_notifier)
    end
  end
end
