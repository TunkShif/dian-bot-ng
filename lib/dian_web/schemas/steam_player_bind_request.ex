defmodule DianWeb.Schemas.SteamPlayerBindRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SteamPlayerBindRequest",
    description: "Request body for binding a Steam ID to a QQ ID.",
    type: :object,
    required: [:steam_id],
    properties: %{
      steam_id: %Schema{
        type: :string,
        description: "17-digit Steam ID",
        example: "76561198012345678"
      }
    }
  })
end
