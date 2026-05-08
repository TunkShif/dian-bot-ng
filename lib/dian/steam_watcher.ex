defmodule Dian.SteamWatcher do
  @moduledoc """
  Runtime API for Steam player watching.
  """

  alias Dian.SteamWatcher.AchievementPoller
  alias Dian.SteamWatcher.AchievementUnlocked
  alias Dian.SteamWatcher.StatusPoller
  alias Dian.SteamWatcher.StatusChanged

  def check_status_now do
    StatusPoller.check_now()
  end

  def subscribe_status do
    StatusPoller.subscribe()
  end

  def broadcast_status_changed(%StatusChanged{} = event) do
    StatusPoller.broadcast_status_changed(event)
  end

  def check_achievements_now do
    AchievementPoller.check_now()
  end

  def subscribe_achievements do
    AchievementPoller.subscribe()
  end

  def broadcast_achievement_unlocked(%AchievementUnlocked{} = event) do
    AchievementPoller.broadcast_achievement_unlocked(event)
  end
end
