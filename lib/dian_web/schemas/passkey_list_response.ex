defmodule DianWeb.Schemas.PasskeyListResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PasskeyListResponse",
    description: "JSend success envelope containing passkeys for the current user.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:passkeys],
        properties: %{
          passkeys: %Schema{
            type: :array,
            items: %Schema{
              type: :object,
              required: [:id, :label, :last_used_at, :inserted_at, :updated_at],
              properties: %{
                id: %Schema{type: :integer, example: 1},
                label: %Schema{type: :string, example: "Laptop"},
                last_used_at: %Schema{type: :string, format: :"date-time", nullable: true},
                inserted_at: %Schema{type: :string, format: :"date-time"},
                updated_at: %Schema{type: :string, format: :"date-time"}
              }
            }
          }
        }
      }
    }
  })
end
