defmodule Dian.SteamWatcher do
  @moduledoc """
  Runtime API for Steam player watching.
  """

  alias Dian.SteamWatcher.Poller
  alias Dian.SteamWatcher.StatusChanged

  def check_now do
    Poller.check_now()
  end

  def subscribe do
    Poller.subscribe()
  end

  def broadcast_status_changed(%StatusChanged{} = event) do
    Poller.broadcast_status_changed(event)
  end
end
