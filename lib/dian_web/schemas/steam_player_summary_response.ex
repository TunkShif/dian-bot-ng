defmodule DianWeb.Schemas.SteamPlayerSummaryResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SteamPlayerSummaryResponse",
    description: "JSend success envelope containing a Steam player summary.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:player],
        properties: %{
          player: %Schema{
            type: :object,
            required: [:steam_id, :name, :profile_url, :avatar_url, :state],
            properties: %{
              steam_id: %Schema{type: :string, example: "76561198012345678"},
              name: %Schema{type: :string, example: "PlayerOne"},
              profile_url: %Schema{
                type: :string,
                example: "https://steamcommunity.com/id/playerone/"
              },
              avatar_url: %Schema{
                type: :string,
                example:
                  "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg"
              },
              state: %Schema{
                type: :string,
                enum: ["offline", "online", "busy", "away", "snooze"],
                example: "online"
              },
              last_logoff: %Schema{type: :integer, nullable: true, example: 1_700_000_000},
              created_at: %Schema{type: :integer, nullable: true, example: 1_500_000_000},
              playing_game_id: %Schema{type: :string, nullable: true, example: "730"},
              playing_game_name: %Schema{
                type: :string,
                nullable: true,
                example: "Counter-Strike 2"
              }
            }
          }
        }
      }
    }
  })
end
