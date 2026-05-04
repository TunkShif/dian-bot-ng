defmodule Dian.Steam.PlayerSummary do
  defstruct [
    :steam_id,
    :name,
    :profile_url,
    :avatar_url,
    :state,
    :last_logoff,
    :created_at,
    :playing_game_id,
    :playing_game_name
  ]

  @type t :: %__MODULE__{
          steam_id: String.t() | nil,
          name: String.t() | nil,
          profile_url: String.t() | nil,
          avatar_url: String.t() | nil,
          state: :offline | :online | :busy | :away | :snooze | nil,
          last_logoff: integer() | nil,
          created_at: integer() | nil,
          playing_game_id: String.t() | nil,
          playing_game_name: String.t() | nil
        }

  def build(params) do
    %__MODULE__{
      steam_id: params["steamid"],
      name: params["personaname"],
      profile_url: params["profileurl"],
      avatar_url: params["avatarfull"],
      state: params["personastate"] |> to_state(),
      last_logoff: params["lastlogoff"],
      created_at: params["timecreated"],
      playing_game_id: params["gameid"],
      playing_game_name: params["gameextrainfo"]
    }
  end

  defp to_state(0), do: :offline
  defp to_state(1), do: :online
  defp to_state(2), do: :busy
  defp to_state(3), do: :away
  defp to_state(4), do: :snooze
  defp to_state(_), do: nil
end
