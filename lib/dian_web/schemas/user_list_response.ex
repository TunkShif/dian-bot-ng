defmodule DianWeb.Schemas.UserListResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "UserListResponse",
    description: "JSend success envelope containing all registered users.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:users],
        properties: %{
          users: %Schema{
            type: :array,
            items: %Schema{
              type: :object,
              required: [:id, :email, :inserted_at],
              properties: %{
                id: %Schema{type: :integer, example: 1},
                email: %Schema{type: :string, format: :email, example: "123456789@qq.com"},
                confirmed_at: %Schema{type: :string, format: :datetime, nullable: true},
                inserted_at: %Schema{type: :string, format: :datetime}
              }
            }
          }
        }
      }
    }
  })
end
