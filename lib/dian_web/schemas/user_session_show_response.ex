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
                required: [:id, :email],
                properties: %{
                  id: %Schema{type: :integer, example: 1},
                  email: %Schema{type: :string, format: :email, example: "123456@qq.com"},
                  confirmed_at: %Schema{
                    type: :string,
                    format: :"date-time",
                    nullable: true,
                    example: "2026-05-03T12:00:00Z"
                  },
                  authenticated_at: %Schema{
                    type: :string,
                    format: :"date-time",
                    nullable: true,
                    example: "2026-05-03T12:00:00Z"
                  },
                  inserted_at: %Schema{
                    type: :string,
                    format: :"date-time",
                    example: "2026-05-03T12:00:00Z"
                  },
                  updated_at: %Schema{
                    type: :string,
                    format: :"date-time",
                    example: "2026-05-03T12:00:00Z"
                  }
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
          "confirmed_at" => "2026-05-03T12:00:00Z",
          "authenticated_at" => "2026-05-03T12:00:00Z",
          "inserted_at" => "2026-05-03T12:00:00Z",
          "updated_at" => "2026-05-03T12:00:00Z"
        }
      }
    }
  })
end
