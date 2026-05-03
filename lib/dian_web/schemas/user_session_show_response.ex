defmodule DianWeb.Schemas.UserSessionShowResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "UserSessionShowResponse",
    description: "JSend success envelope containing the current user when authenticated.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:user],
        properties: %{
          user: %Schema{
            nullable: true,
            oneOf: [
              %Schema{
                type: :object,
                required: [:id, :email, :qq_id],
                properties: %{
                  id: %Schema{type: :integer, example: 1},
                  email: %Schema{type: :string, format: :email, example: "123456@qq.com"},
                  qq_id: %Schema{type: :string, example: "123456"}
                }
              }
            ]
          }
        }
      }
    },
    example: %{
      "status" => "success",
      "data" => %{
        "user" => %{
          "id" => 1,
          "email" => "123456@qq.com",
          "qq_id" => "123456"
        }
      }
    }
  })
end
