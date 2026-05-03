defmodule DianWeb.Schemas.UserSettingsUpdateRequest do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "UserSettingsUpdateRequest",
    description: "Settings update request for the authenticated user.",
    type: :object,
    required: [:user],
    properties: %{
      user: %Schema{
        type: :object,
        required: [:password],
        properties: %{
          password: %Schema{
            type: :string,
            format: :password,
            minLength: 12,
            maxLength: 72,
            example: "new valid password"
          },
          password_confirmation: %Schema{
            type: :string,
            format: :password,
            example: "new valid password"
          }
        }
      }
    },
    example: %{
      "user" => %{
        "password" => "new valid password",
        "password_confirmation" => "new valid password"
      }
    }
  })
end
