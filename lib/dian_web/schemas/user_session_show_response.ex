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
                required: [:id, :qq_id, :nickname, :avatar_url],
                properties: %{
                  id: %Schema{type: :integer, example: 1},
                  qq_id: %Schema{type: :string, example: "123456"},
                  nickname: %Schema{type: :string, example: "Dian User"},
                  avatar_url: %Schema{
                    type: :string,
                    format: :uri,
                    example: "https://q1.qlogo.cn/g?b=qq&nk=123456&s=640"
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
          "qq_id" => "123456",
          "nickname" => "Dian User",
          "avatar_url" => "https://q1.qlogo.cn/g?b=qq&nk=123456&s=640"
        }
      }
    }
  })
end
