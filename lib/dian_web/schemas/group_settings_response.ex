defmodule DianWeb.Schemas.GroupSettingsResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "GroupSettingsResponse",
    description: "JSend success envelope containing updated group settings.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:group],
        properties: %{
          group: %Schema{
            type: :object,
            required: [
              :id,
              :enabled,
              :steam_status_enabled,
              :steam_achievements_enabled,
              :daily_steam_summary_enabled
            ],
            properties: %{
              id: %Schema{type: :string, example: "100"},
              enabled: %Schema{type: :boolean, example: true},
              steam_status_enabled: %Schema{type: :boolean, example: true},
              steam_achievements_enabled: %Schema{type: :boolean, example: true},
              daily_steam_summary_enabled: %Schema{type: :boolean, example: true}
            }
          }
        }
      }
    }
  })
end
