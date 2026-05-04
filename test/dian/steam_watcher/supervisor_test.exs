defmodule Dian.SteamWatcher.SupervisorTest do
  use ExUnit.Case, async: false

  alias Dian.SteamWatcher

  describe "start_link/1" do
    test "starts the watcher poller and notifier" do
      supervisor = Process.whereis(SteamWatcher.Supervisor)

      children = Supervisor.which_children(supervisor)

      assert {SteamWatcher.Poller, poller, :worker, [SteamWatcher.Poller]} =
               List.keyfind(children, SteamWatcher.Poller, 0)

      assert {SteamWatcher.Notifier, notifier, :worker, [SteamWatcher.Notifier]} =
               List.keyfind(children, SteamWatcher.Notifier, 0)

      assert is_pid(poller)
      assert is_pid(notifier)

      :sys.get_state(poller)
      :sys.get_state(notifier)
    end
  end
end
