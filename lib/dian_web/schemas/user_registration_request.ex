defmodule DianWeb.Schemas.UserRegistrationRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "UserRegistrationRequest",
    description: "Registration request for a QQ email account.",
    type: :object,
    required: [:user],
    properties: %{
      user: %Schema{
        type: :object,
        required: [:email],
        properties: %{
          email: %Schema{
            type: :string,
            format: :email,
            pattern: "^\\d{5,13}@qq\\.com$",
            example: "123456@qq.com"
          }
        }
      }
    },
    example: %{
      "user" => %{
        "email" => "123456@qq.com"
      }
    }
  })
end
