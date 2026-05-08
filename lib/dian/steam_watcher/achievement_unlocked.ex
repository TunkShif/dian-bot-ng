defmodule Dian.SteamWatcher.AchievementUnlocked do
  @enforce_keys [:steam_id, :qq_id, :app_id, :game_name, :achievements, :changed_at]
  defstruct [:steam_id, :qq_id, :app_id, :game_name, :achievements, :changed_at]

  defmodule Item do
    @enforce_keys [:api_name, :unlocktime]
    defstruct [:api_name, :display_name, :description, :icon_url, :unlocktime, :hidden]
  end
end
