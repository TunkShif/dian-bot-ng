defmodule DianWeb.SteamPlayerJSON do
  alias Dian.Steam.PlayerSummary
  alias Dian.Steam.SteamPlayer

  def summary(%PlayerSummary{} = player) do
    %{
      steam_id: player.steam_id,
      name: player.name,
      profile_url: player.profile_url,
      avatar_url: player.avatar_url,
      state: player.state,
      last_logoff: player.last_logoff,
      created_at: player.created_at,
      playing_game_id: player.playing_game_id,
      playing_game_name: player.playing_game_name
    }
  end

  def binding(%SteamPlayer{} = steam_player) do
    %{
      steam_id: steam_player.steam_id,
      qq_id: steam_player.qq_id
    }
  end
end
