defmodule Dian.SteamWatcher.Poller do
  @moduledoc false

  def child_spec(opts), do: Dian.SteamWatcher.StatusPoller.child_spec(opts)
  defdelegate start_link(opts \\ []), to: Dian.SteamWatcher.StatusPoller

  defdelegate check_now(server \\ Dian.SteamWatcher.StatusPoller),
    to: Dian.SteamWatcher.StatusPoller

  defdelegate subscribe(), to: Dian.SteamWatcher.StatusPoller
  defdelegate broadcast_status_changed(event), to: Dian.SteamWatcher.StatusPoller
end
