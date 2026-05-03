defmodule DianWeb.Schemas.PasskeyBeginResponse do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PasskeyBeginResponse",
    description: "JSend success envelope containing WebAuthn public key options.",
    type: :object,
    required: [:status, :data],
    properties: %{
      status: %Schema{type: :string, enum: ["success"], example: "success"},
      data: %Schema{
        type: :object,
        required: [:options],
        properties: %{
          options: %Schema{
            type: :object,
            additionalProperties: true,
            example: %{
              "challenge" => "eyJjaGFsbGVuZ2UiOiJleGFtcGxlIn0",
              "rpId" => "localhost",
              "userVerification" => "preferred"
            }
          }
        }
      }
    }
  })
end
