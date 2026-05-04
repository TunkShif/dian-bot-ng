defmodule Dian.SteamWatcher.StatusChanged do
  @enforce_keys [:steam_id, :qq_id, :changed_at]
  defstruct [
    :steam_id,
    :qq_id,
    :previous_game_id,
    :previous_game_name,
    :current_game_id,
    :current_game_name,
    :changed_at
  ]
end
