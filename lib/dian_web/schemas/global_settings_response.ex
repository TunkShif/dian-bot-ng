defmodule DianWeb.Schemas.GlobalSettingsResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "GlobalSettingsResponse",
    description: "JSend success envelope containing global system settings.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:superadmin, :group_count, :enabled_group_count],
        properties: %{
          superadmin: %Schema{
            nullable: true,
            oneOf: [
              %Schema{
                type: :object,
                required: [:id, :email],
                properties: %{
                  id: %Schema{type: :integer, example: 1},
                  email: %Schema{type: :string, format: :email, example: "123456789@qq.com"}
                }
              }
            ]
          },
          group_count: %Schema{type: :integer, example: 5},
          enabled_group_count: %Schema{type: :integer, example: 3}
        }
      }
    }
  })
end
