defmodule DianWeb.Schemas.SteamPlayerBindingResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SteamPlayerBindingResponse",
    description: "JSend success envelope containing the upserted Steam player binding.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:binding],
        properties: %{
          binding: %Schema{
            type: :object,
            required: [:steam_id, :qq_id],
            properties: %{
              steam_id: %Schema{type: :string, example: "76561198012345678"},
              qq_id: %Schema{type: :string, example: "123456789"}
            }
          }
        }
      }
    }
  })
end
