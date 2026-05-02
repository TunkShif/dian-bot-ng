defmodule DianWeb.Schemas.UserLoginRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "UserLoginRequest",
    description:
      "Login request. Include only email to request a magic link, or include password for password login.",
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
          },
          password: %Schema{
            type: :string,
            format: :password,
            minLength: 12,
            maxLength: 72,
            example: "hello world!"
          },
          remember_me: %Schema{
            type: :string,
            enum: ["true"],
            example: "true"
          }
        }
      }
    },
    examples: [
      %{
        "user" => %{
          "email" => "123456@qq.com"
        }
      },
      %{
        "user" => %{
          "email" => "123456@qq.com",
          "password" => "hello world!",
          "remember_me" => "true"
        }
      }
    ]
  })
end
