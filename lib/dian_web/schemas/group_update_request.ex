defmodule DianWeb.Schemas.GroupUpdateRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "GroupUpdateRequest",
    description: "Group settings update params.",
    type: :object,
    properties: %{
      enabled: %Schema{type: :boolean, example: true},
      steam_status_enabled: %Schema{type: :boolean, example: true},
      steam_achievements_enabled: %Schema{type: :boolean, example: true},
      daily_steam_summary_enabled: %Schema{type: :boolean, example: true}
    }
  })
end
